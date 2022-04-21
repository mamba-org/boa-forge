import logging
import subprocess
from os import chdir
from pathlib import Path

from get_latest_conda_package import get_version_file


def get_latest_pkg(some_dir):
    sort_key = lambda f: f.stat().st_mtime

    directory = Path(some_dir)
    files = directory.glob("*.bz2")
    sorted_files = sorted(files, key=sort_key, reverse=True)
    if len(sorted_files) > 0:
        file = sorted_files[0]
    else:
        file = "empty"
    return file


def getName_andTag(pkg):
    logging.warning(f"Pkg is: <<{pkg}>>")
    name, version, a_hash = pkg.rsplit("-", 2)

    tag = version + "-" + a_hash
    tag_resized = tag.rpartition(".tar")[0]
    tag_resized = tag_resized.replace("_", "-")

    return name, tag_resized


def split_name(data, host):

    logging.warning(f"Data1!!! is: <<{data}>>")
    sep = "/"
    strData = str(data)
    if "win" in host:
        sep = "\\"
    pkg = str(data).rsplit(sep, 1)[-1]
    length = len(strData) - len(pkg)
    path = strData[:length]
    pkg_name, tag = getName_andTag(pkg)
    origin = pkg
    return pkg_name, tag, path, origin, pkg


def write_version(some_dict, data, host):
    some_dir = data
    logging.warning(f"Data is: <<{data}>>")
    whole_path = get_latest_pkg(some_dir)
    logging.warning(f"File is: {whole_path}")
    if whole_path == "empty":
        return some_dict
    else:
        pkg_name, _, _, _, _ = split_name(whole_path, host)
        version = get_version_file(some_dir, pkg_name)[1]
        if pkg_name in some_dict.keys():
            old_ver = some_dict[pkg_name]
            logging.warning(f"Comparing <<{old_ver}>> and <<{version}>>")

            if version > old_ver:
                some_dict[pkg_name] = version

        else:
            some_dict[pkg_name] = version
        return some_dict


def install_on_OS(sys):
    logging.warning(f"Installing oras on {sys}...")
    if "os" in sys:
        subprocess.run(
            "curl -LO https://github.com/oras-project/oras/releases/download/v0.12.0/oras_0.12.0_darwin_amd64.tar.gz",
            shell=True,
        )
        location = Path("oras-install")
        location.mkdir(mode=511, parents=False, exist_ok=True)
        subprocess.run("tar -zxf oras_0.12.0_*.tar.gz -C oras-install/", shell=True)
        subprocess.run("mv oras-install/oras /usr/local/bin/", shell=True)
        subprocess.run("rm -rf oras_0.12.0_*.tar.gz oras-install/", shell=True)
    elif "win" in sys:
        subprocess.run(
            "curl.exe -sLO  https://github.com/oras-project/oras/releases/download/v0.12.0/oras_0.12.0_windows_amd64.tar.gz",
            shell=True,
        )
        subprocess.run("tar.exe -xvzf oras_0.12.0_windows_amd64.tar.gz", shell=True)
        mdir_cmd = "mkdir -p %USERPROFILE%\\bin\\"
        subprocess.run(mdir_cmd, shell=True)
        copy_cmd = "copy oras.exe %USERPROFILE%\\bin\\"
        subprocess.run(copy_cmd, shell=True)
        setPath_cmd = "set PATH=%USERPROFILE%\\bin\\;%PATH%"
        subprocess.run(setPath_cmd, shell=True)


class Oras:
    def __init__(self, github_owner, user_token, origin, system):
        self.owner = github_owner
        self.conda_prefix = origin
        self.token = user_token
        if "win" in str(system):
            self.strSys = "win-64"
        else:
            self.strSys = str(system)
        logging.warning(f"Host is <<{self.strSys}>>")
        if "osx" in self.strSys or "win" in self.strSys:
            install_on_OS(system)

    def login(self):
        loginStr = f"echo {self.token} | oras login https://ghcr.io -u {self.owner} --password-stdin"
        subprocess.run(loginStr, shell=True)

    def push_repodata(self, the_dir):
        # create the repodata file
        logging.warning("Build the repodata file using conda index command")
        subprocess.run(f"conda index {str(the_dir)}", shell=True)
        repo = "repodata.json"

        upload_cmd = f"oras push ghcr.io/{self.owner}/samples/{self.strSys}/repodata.json:latest {repo}:application/json"
        logging.warning(f"upload the json file using following command: <<{upload_cmd}")
        subprocess.run(upload_cmd, shell=True)

    def push(self, target, data, versions_dict):
        logging.warning(f"current dic is: {versions_dict}")
        pkg_name, tag, path, origin, pkg = split_name(data, self.strSys)

        # upload the tar_bz2 file to the right url
        push_bz2 = f"oras push ghcr.io/{self.owner}/samples/{target}/{pkg_name}:{tag} {origin}:application/octet-stream"
        push_bz2_latest = f"oras push ghcr.io/{self.owner}/samples/{target}/{pkg_name}:latest {origin}:application/octet-stream"
        upload_url = f"ghcr.io/{self.owner}/samples/{target}/{pkg_name}:{tag}"
        upload_url_lat = f"ghcr.io/{self.owner}/samples/{target}/{pkg_name}:latest"
        logging.warning(f"Cmd <<{push_bz2}>>")
        logging.warning(f"Latest Cmd <<{push_bz2_latest}>>")
        chdir(path)
        logging.warning(
            f"Uploading <<{pkg}>>. path <<{origin} (from dir: << {self.conda_prefix} >> to link: <<{upload_url}>>"
        )
        subprocess.run(push_bz2, shell=True)
        logging.warning(f"Package <<{pkg_name}>> uploaded to: <<{upload_url}>>")

        can_be_pushed = False
        current_version = get_version_file(path, pkg_name)[1]
        if pkg_name in versions_dict.keys():
            old_version = versions_dict[pkg_name]
            logging.warning(
                f"Two versions of package <<{pkg_name}>> found: current version: <<{current_version}>> old version:<<{old_version}>>"
            )

            if current_version != old_version:
                logging.warning(f"new version found: <<{current_version}>>")
                can_be_pushed = True
        else:
            can_be_pushed = True

        if can_be_pushed:
            logging.warning(
                f"Uploading <<{pkg}>> with tag latest with cmd <<{push_bz2_latest}>>"
            )
            subprocess.run(push_bz2_latest, shell=True)
            versions_dict[pkg_name] = current_version
            # versions_dict = write_version(versions_dict, data)
            logging.warning(f"Package <<{pkg_name}>> uploaded to: <<{upload_url_lat}>>")
        else:
            logging.warning(
                f"This Version {current_version} of <<{pkg_name}>> cannot be tagged as latest, because there is a newer version"
            )

        return versions_dict

    def pull(self, pkg, tag, a_dir, versions_dict):
        pullCmd = f'oras pull ghcr.io/{self.owner}/samples/{self.strSys}/{pkg}:{tag} --output {a_dir} -t "application/octet-stream"'

        logging.warning(f"Pulling lattest of  <<{pkg}>>. with command: <<{pullCmd}>>")
        try:
            subprocess.run(pullCmd, shell=True)
        except subprocess.CalledProcessError:
            logging.warning(f"Package <<{pkg}>> did not exist on the registry")
            logging.warning("Upload aborted!")
            return versions_dict
        else:
            logging.warning(f"Latest version of  <<{pkg}>> pulled")
            versions_dict = write_version(versions_dict, a_dir, self.strSys)

        return versions_dict
