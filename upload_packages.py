import json
import logging
import sys
from logging import warning
from pathlib import Path

from oras import Oras

# initializations
owner = sys.argv[1]
target_platform = str(sys.argv[2])
conda_prefix = sys.argv[3]
token = sys.argv[4]

with open("versions.json", "r") as read_file:
    versions_dict = json.load(read_file)
# create oras object and login with the token
oras = Oras(owner, token, conda_prefix, target_platform)

oras.login()

directory = "conda-bld"
if "windows" in target_platform:
    target_platform = "win-64"
    # C:\Users\runneradmin\micromamba\envs\buildenv\conda-bld\win-64\
    location = Path(conda_prefix) / directory
    for data in location.iterdir():
        strFile = str(data)
        if strFile.endswith("win-64"):
            for pkg in data.iterdir():
                strPkg = str(pkg)
                logging.warning(f"pkg: <<{pkg}>>")
                if strPkg.endswith("tar.bz2"):
                    versions_dict = oras.push(target_platform, pkg, versions_dict)

else:
    location = Path(conda_prefix) / directory / target_platform
    warning(f"location <<{location}>>")
    # push the all found packages to the registry
    for data in location.iterdir():
        strFile = str(data)
        if strFile.endswith("tar.bz2"):
            versions_dict = oras.push(target_platform, data, versions_dict)
