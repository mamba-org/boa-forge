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


def split_name(data):
    logging.warning(f"Data1!!! is: <<{data}>>")

    strData = str(data)
    pkg = str(data).rsplit("/", 1)[-1]
    length = len(strData) - len(pkg)
    path = strData[:length]
    pkg_name, tag = getName_andTag(pkg)
    origin = "./" + pkg
    return pkg_name, tag, path, origin, pkg


def write_version(some_dict, data):
    some_dir = data
    logging.warning(f"Data is: <<{data}>>")
    whole_path = get_latest_pkg(some_dir)
    if whole_path == "empty":
        return some_dict
    pkg_name, _, _, _, _ = split_name(whole_path)
    version = get_version_file(some_dir, pkg_name)[1]
    if pkg_name in some_dict.keys():
        if some_dict[pkg_name] < version:
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
        self.strSys = str(system)
        logging.warning(f"Host is <<{self.strSys}>>")
        if "osx" in self.strSys or "win" in self.strSys:
            install_on_OS(system)

    def login(self):
        loginStr = f"echo {self.token} | oras login https://ghcr.io -u {self.owner} --password-stdin"
        subprocess.run(loginStr, shell=True)

    def push(self, target, data, versions_dict):
        pkg_name, tag, path, origin, pkg = split_name(data)

        # upload the tar_bz2 file to the right url
        push_bz2 = f"oras push ghcr.io/{self.owner}/samples/{target}/{pkg_name}:{tag} {origin}:application/octet-stream"
        push_bz2_latest = f"oras push ghcr.io/{self.owner}/samples/{target}/{pkg_name}:latest {origin}:application/octet-stream"
        upload_url = f"ghcr.io/{self.owner}/samples/{target}/{pkg_name}:{tag}"
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
            t1 = type(pkg_name)
            logging.warning(f"pkg_name: {pkg_name} type: {t1}")

            if current_version > versions_dict[pkg_name]:
                t = type(current_version)
                logging.warning(f"curr is {current_version} type :{t}")

                can_be_pushed = True
        else:
            can_be_pushed = True

        if can_be_pushed:
            logging.warning(f"Uploading <<{pkg}>> with tag latest")
            subprocess.run(push_bz2_latest, shell=True)
            versions_dict = write_version(versions_dict, data)
            logging.warning(f"Package <<{pkg_name}>> uploaded to: <<{upload_url}>>")
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
        except BaseException:
            logging.warning(f"Package <<{pkg}>> did not exist on the registry")
            logging.warning("Upload aborted!")
        else:
            logging.warning(f"Latest version of  <<{pkg}>> pulled")
            versions_dict = write_version(versions_dict, a_dir)
        return versions_dict
