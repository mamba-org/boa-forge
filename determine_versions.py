import abc, re, copy
import feedparser
import collections.abc
from typing import Optional
from conda.models.version import VersionOrder

import ruamel, jinja2, requests, time, hashlib, math
from ruamel.yaml import YAML
from collections import OrderedDict
from multiprocessing import Process, Pipe
from ruamel.yaml.representer import RoundTripRepresenter

RECIPE_FIELD_ORDER = [
    "context",
    "package",
    "source",
    "build",
    "requirements",
    "test",
    "features",
    "app",
    "outputs",
    "about",
    "extra",
]

class MyRepresenter(RoundTripRepresenter):
    pass

ruamel.yaml.add_representer(
    OrderedDict, MyRepresenter.represent_dict, representer=MyRepresenter
)

class AbstractSource(abc.ABC):
    name: str

    @abc.abstractmethod
    def get_version(self, url: str) -> Optional[str]:
        pass

    @abc.abstractmethod
    def get_url(self, meta_yaml) -> Optional[str]:
        pass

class VersionFromFeed(AbstractSource):
    ver_prefix_remove = ["release-", "releases%2F", "v_", "v.", "v"]
    dev_vers = [
        "rc",
        "beta",
        "alpha",
        "dev",
        "a",
        "b",
        "init",
        "testing",
        "test",
        "pre",
    ]

    def get_version(self, url) -> Optional[str]:
        data = feedparser.parse(url)
        if data["bozo"] == 1:
            return None
        vers = []
        for entry in data["entries"]:
            ver = entry["link"].split("/")[-1]
            for prefix in self.ver_prefix_remove:
                if ver.startswith(prefix):
                    ver = ver[len(prefix) :]
            if any(s in ver.lower() for s in self.dev_vers):
                continue
            # Extract version number starting at the first digit.
            ver = re.search(r"(\d+[^\s]*)", ver).group(0)
            vers.append(ver)
        if vers:
            return max(vers, key=lambda x: VersionOrder(x.replace("-", ".")))
        else:
            return None

class Github(VersionFromFeed):
    name = "github"

    def get_url(self, meta_yaml) -> Optional[str]:
        if "github.com" not in meta_yaml["source"][0]["url"]:
            return None
        split_url = meta_yaml["source"][0]["url"].lower().split("/")
        package_owner = split_url[split_url.index("github.com") + 1]
        gh_package_name = split_url[split_url.index("github.com") + 2]
        return f"https://github.com/{package_owner}/{gh_package_name}/releases.atom"

def ensure_list(x):
    if not isinstance(x, list):
        return [x]
    else:
        return x

def _hash_url(url, hash_type, progress=False, conn=None, timeout=None):
    _hash = None
    try:
        ha = getattr(hashlib, hash_type)()

        timedout = False
        t0 = time.time()

        resp = requests.get(url, stream=True, timeout=timeout or 10)

        if timeout is not None:
            if time.time() - t0 > timeout:
                timedout = True

        if resp.status_code == 200 and not timedout:
            if "Content-length" in resp.headers:
                num = math.ceil(float(resp.headers["Content-length"]) / 8192)
            elif resp.url != url:
                # redirect for download
                h = requests.head(resp.url).headers
                if "Content-length" in h:
                    num = math.ceil(float(h["Content-length"]) / 8192)
                else:
                    num = None
            else:
                num = None

            loc = 0
            for itr, chunk in enumerate(resp.iter_content(chunk_size=8192)):
                ha.update(chunk)
                if num is not None and int((itr + 1) / num * 25) > loc and progress:
                    eta = (time.time() - t0) / (itr + 1) * (num - (itr + 1))
                    loc = int((itr + 1) / num * 25)
                    print(
                        "eta % 7.2fs: [%s%s]"
                        % (eta, "".join(["=" * loc]), "".join([" " * (25 - loc)])),
                    )
                if timeout is not None:
                    if time.time() - t0 > timeout:
                        timedout = True

            if not timedout:
                _hash = ha.hexdigest()
            else:
                _hash = None
        else:
            _hash = None
    except requests.ConnectionError:
        _hash = None
    except Exception as e:
        _hash = (repr(e),)
    finally:
        if conn is not None:
            conn.send(_hash)
            conn.close()
        else:
            return _hash


def hash_url(url, timeout=None, progress=False, hash_type="sha256"):
    """Hash a url with a timeout.

    Parameters
    ----------
    url : str
        The URL to hash.
    timeout : int, optional
        The timeout in seconds. If the operation goes longer than
        this amount, the hash will be returned as None. Set to `None`
        for no timeout.
    progress : bool, optional
        If True, show a simple progress meter.
    hash_type : str
        The kind of hash. Must be an attribute of `hashlib`.

    Returns
    -------
    hash : str or None
        The hash, possibly None if the operation timed out or the url does
        not exist.
    """
    _hash = None

    try:
        parent_conn, child_conn = Pipe()
        p = Process(
            target=_hash_url,
            args=(url, hash_type),
            kwargs={"progress": progress, "conn": child_conn},
        )
        p.start()
        if parent_conn.poll(timeout):
            _hash = parent_conn.recv()

        p.join(timeout=0)
        if p.exitcode != 0:
            p.terminate()
    except AssertionError as e:
        # if launched in a process we cannot use another process
        if "daemonic" in repr(e):
            _hash = _hash_url(
                url,
                hash_type,
                progress=progress,
                conn=None,
                timeout=timeout,
            )
        else:
            raise e

    if isinstance(_hash, tuple):
        raise eval(_hash[0])

    return _hash

def order_output_dict(d):
    result_list = []
    for k in RECIPE_FIELD_ORDER:
        if k in d:
            result_list.append((k, d[k]))

    leftover_keys = d.keys() - set(RECIPE_FIELD_ORDER)
    result_list += [(k, d[k]) for k in leftover_keys]
    return OrderedDict(result_list)

def get_yaml_loader(typ):
    if typ == "rt":
        loader = YAML(typ=typ)
        loader.preserve_quotes = True
        loader.default_flow_style = False
        loader.indent(sequence=4, offset=2)
        loader.width = 1000
        loader.Representer = MyRepresenter
        loader.Loader = ruamel.yaml.RoundTripLoader
    elif typ == "safe":
        loader = YAML(typ=typ)
    return loader

def render_recursive(dict_or_array, context_dict, jenv):
    # check if it's a dict?
    if isinstance(dict_or_array, collections.abc.Mapping):
        for key, value in dict_or_array.items():
            if isinstance(value, str):
                tmpl = jenv.from_string(value)
                dict_or_array[key] = tmpl.render(context_dict)
            elif isinstance(value, collections.abc.Mapping):
                render_recursive(dict_or_array[key], context_dict, jenv)
            elif isinstance(value, collections.abc.Iterable):
                render_recursive(dict_or_array[key], context_dict, jenv)

def normalize_recipe(ydoc):
    # normalizing recipe:
    # sources -> list
    # every output -> to outputs list
    if ydoc.get("context"):
        del ydoc["context"]

    if ydoc.get("source"):
        ydoc["source"] = ensure_list(ydoc["source"])

    if not ydoc.get("outputs"):
        ydoc["outputs"] = [{"package": ydoc["package"]}]

        toplevel_output = ydoc["outputs"][0]
    else:
        for o in ydoc["outputs"]:
            if o["package"]["name"] == ydoc["package"]["name"]:
                toplevel_output = o
                break
        else:
            # how do we handle no-output toplevel?!
            toplevel_output = None
            assert not ydoc.get("requirements")

    if ydoc.get("requirements"):
        # move these under toplevel output
        assert not toplevel_output.get("requirements")
        toplevel_output["requirements"] = ydoc["requirements"]
        del ydoc["requirements"]

    if ydoc.get("test"):
        # move these under toplevel output
        assert not toplevel_output.get("test")
        toplevel_output["test"] = ydoc["test"]
        del ydoc["test"]

    def move_to_toplevel(key):
        if ydoc.get("build", {}).get(key):
            if not toplevel_output.get("build"):
                toplevel_output["build"] = {}
            toplevel_output["build"][key] = ydoc["build"][key]
            del ydoc["build"][key]

    move_to_toplevel("run_exports")
    move_to_toplevel("ignore_run_exports")

    return ydoc

def get_raw_yaml(recipe_path):
    f = open(recipe_path, 'r')
    loader = get_yaml_loader(typ="rt")
    raw_yaml = loader.load(f)
    context_dict = raw_yaml.get("context") or {}
    return raw_yaml, context_dict

def get_rendered_yaml(raw_yaml, context_dict):
    rendered_yaml = copy.deepcopy(raw_yaml)
    jenv = jinja2.Environment()
    for key, value in context_dict.items():
        if isinstance(value, str):
            tmpl = jenv.from_string(value)
            context_dict[key] = tmpl.render(context_dict)

    for key in rendered_yaml:
        render_recursive(rendered_yaml[key], context_dict, jenv)

    rendered_yaml = normalize_recipe(rendered_yaml)
    return rendered_yaml

def is_new_version_available(rendered_yaml):
    current_version = rendered_yaml["package"]["version"]
    github_url = Github().get_url(rendered_yaml)
    if github_url is not None:
        github_version = Github().get_version(github_url)
        if VersionOrder(github_version) > VersionOrder(current_version):
            return True, github_version
    return False, current_version

def get_new_url_for_new_version(raw_yaml, rendered_yaml, context_dict, version_available, new_version):
    raw_yaml["context"]["version"] = new_version
    context_dict["version"] = new_version
    if version_available:
        rendered_yaml = get_rendered_yaml(raw_yaml, context_dict)
    return rendered_yaml["source"][0]["url"]

def get_sha256(url: str) -> Optional[str]:
    try:
        return hash_url(url, timeout=120, hash_type="sha256")
    except Exception as e:
        print("url hashing exception: %s", repr(e))
        return None

def get_updated_raw_yaml(recipe_path):
    raw_yaml, context_dict = get_raw_yaml(recipe_path)
    rendered_yaml = get_rendered_yaml(raw_yaml, context_dict)
    version_available, new_version = is_new_version_available(rendered_yaml)
    url_for_version = get_new_url_for_new_version(raw_yaml, rendered_yaml, context_dict, version_available, new_version)
    sha256_hash_for_version = get_sha256(url_for_version)
    sha256_hash_for_current = rendered_yaml["source"][0]["sha256"]
    if sha256_hash_for_version is not None and sha256_hash_for_version != sha256_hash_for_current:
        if type(raw_yaml["source"]) == list:
            raw_yaml["source"][0]["sha256"] = sha256_hash_for_version
        else:
            raw_yaml["source"]["sha256"] = sha256_hash_for_version
    return raw_yaml

if __name__ == "__main__":
    import glob
    loader = get_yaml_loader(typ="rt")
    recipes = glob.glob("**/recipe.yaml")
    for each_recipe_path in recipes:
        package_name = each_recipe_path.split('/')[0]
        updated_raw_yaml = get_updated_raw_yaml(each_recipe_path)
        fw = open(each_recipe_path, 'w')
        loader.dump(order_output_dict(updated_raw_yaml), fw)
        print(f"Done for {each_recipe_path}")
