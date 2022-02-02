import logging
import subprocess
from pathlib import Path

def getName_andTag(pkg):
    name, version, hash = pkg.rsplit('-', 2)
    
    tag = version + "-" + hash
    tag_resized = tag.rpartition('.tar')[0]
    tag_resized = tag_resized.replace("_", "-")
    
    return name, tag_resized



class Oras:
    def __init__(self, github_owner, origin):
        self.owner = github_owner
        self.conda_prefix = origin
        
    def push(self, target, data ):
        pkg = str(data).rsplit('/', 1)[-1]
        pkg_name, tag = getName_andTag(pkg)

        # upload the tar_bz2 file to the right url
        strData = str(data)
        push_bz2 = f"oras push ghcr.io/{self.owner}/samples/{target}/{pkg_name}:{tag} {strData}:application/octet-stream"
        upload_url = f"ghcr.io/{self.owner}/samples/{target}/{pkg_name}:{tag}"
        curr = Path.cwd()
        logging.warning(f"Uploading <<{pkg_name}>> (from dir: << {self.conda_prefix} >> to link: <<{upload_url}>>")
        logging.warning(f"current dir is <<{curr}>>")
        subprocess.run("ls -al", shell=True)
        subprocess.run(push_bz2, shell=True)
        logging.warning(f"Package <<{pkg_name}>> uploaded to: <<{upload_url}>>")