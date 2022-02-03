import logging
import subprocess
from pathlib import Path
from os import chdir


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
        strData = str(data)
        pkg = str(data).rsplit('/', 1)[-1]
        length = len(strData) - len(pkg)
        path = strData[:length]

        pkg_name, tag = getName_andTag(pkg)

        origin = "./" + pkg

        logging.warning(f"The extracted pkg <<{pkg}>>.")
        logging.warning(f"The path is <<{path}>>.")

        # upload the tar_bz2 file to the right url
        push_bz2 = f"oras push ghcr.io/{self.owner}/samples/{target}/{pkg_name}:{tag} {origin}:application/octet-stream"
        upload_url = f"ghcr.io/{self.owner}/samples/{target}/{pkg_name}:{tag}"
        chdir(path)
        cur = Path.cwd()
        

        logging.warning(f"Uploading <<{pkg}>>. path <<{origin} (from dir: << {self.conda_prefix} >> to link: <<{upload_url}>>")
        logging.warning(f"current dir is <<{cur}>>")
        subprocess.run("ls -al", shell=True)
        subprocess.run(push_bz2, shell=True)
        logging.warning(f"Package <<{pkg_name}>> uploaded to: <<{upload_url}>>")