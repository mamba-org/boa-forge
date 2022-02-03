import logging
import subprocess
from pathlib import Path
from os import chdir
from typing_extensions import Self


def getName_andTag(pkg):
    name, version, hash = pkg.rsplit('-', 2)
    
    tag = version + "-" + hash
    tag_resized = tag.rpartition('.tar')[0]
    tag_resized = tag_resized.replace("_", "-")
    
    return name, tag_resized

def install_on_OS():
    logging.warning("Installing oras on the system...")
    subprocess.run("curl -LO https://github.com/oras-project/oras/releases/download/v0.12.0/oras_0.12.0_darwin_amd64.tar.gz", shell=True)
    location = Path("oras-install")
    location.mkdir(mode=511, parents=False, exist_ok=True)
    subprocess.run("tar -zxf oras_0.12.0_*.tar.gz -C oras-install/", shell=True)
    subprocess.run("mv oras-install/oras /usr/local/bin/", shell=True)
    subprocess.run("rm -rf oras_0.12.0_*.tar.gz oras-install/", shell=True)

class Oras:
    def __init__(self, github_owner,user_token, origin, system):
        self.owner = github_owner
        self.conda_prefix = origin
        self.token = user_token
        strSys = str(system)
        logging.warning(f"Host is <<{strSys}>>")
        if "osx" in strSys:
            install_on_OS
    
    def login(self):
        loginStr = f"echo {self.token} | oras login https://ghcr.io -u {self.owner} --password-stdin"
        subprocess.run(loginStr, shell=True)

    def push(self, target, data ):
        strData = str(data)
        pkg = str(data).rsplit('/', 1)[-1]
        length = len(strData) - len(pkg)
        path = strData[:length]
        pkg_name, tag = getName_andTag(pkg)

        origin = "./" + pkg

        # upload the tar_bz2 file to the right url
        push_bz2 = f"oras push ghcr.io/{self.owner}/samples/{target}/{pkg_name}:{tag} {origin}:application/octet-stream"
        upload_url = f"ghcr.io/{self.owner}/samples/{target}/{pkg_name}:{tag}"
        logging.warning(f"Cmd <<{push_bz2}>>")
        chdir(path)
        cur = Path.cwd()
        

        logging.warning(f"Uploading <<{pkg}>>. path <<{origin} (from dir: << {self.conda_prefix} >> to link: <<{upload_url}>>")
        subprocess.run(push_bz2, shell=True)
        logging.warning(f"Package <<{pkg_name}>> uploaded to: <<{upload_url}>>")
