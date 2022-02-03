from importlib.resources import Package
import logging
import sys
from pathlib import Path
from oras import Oras
import json

#features = sys.argv[1]
owner = sys.argv[1]
pkg_name=  str (sys.argv[2])
target_platform = str (sys.argv[3])
conda_prefix = sys.argv[4]
directory = "conda-bld"

oras = Oras(owner, conda_prefix, target_platform)

base = Path(conda_prefix) / directory
#expl= #/home/runner/micromamba/envs/buildenv/ #conda-bld/
if not base.is_dir():
    logging.warning(f" {base}did NOT exist")
    base.mkdir(mode=511, parents=False, exist_ok=True)

path = base / target_platform
#expl=#/home/runner/micromamba/envs/buildenv/ #conda-bld/ #linux-aarch64/

if not path.is_dir:
    print (f" {path}did NOT exist")
    path.mkdir(mode=511, parents=False, exist_ok=True)(f" {base}did NOT exist")

#import json file
with open("packages.json", "r") as read_file:
    packages_json = json.load(read_file)
packagesList = packages_json["pkgs"]

for pkg in packagesList:
    oras.pull(pkg,"latest",str(path))

# oras pull
#strData = str(conda_prefix)
#pkg = str(data).rsplit('/', 1)[-1]
#length = len(strData) - len(pkg)

#path = strData[:length]



#location = Path(conda_prefix) / directory / target_platform


#/home/runner/micromamba/envs/buildenv/
#conda-bld/
#linux-aarch64/bzip2-static-1.0.8-he8cfe8b_0.tar.bz2

#if base.is_dir():
#    print("yes")
#else:
#    print("no")