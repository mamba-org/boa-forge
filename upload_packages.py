import sys
from pathlib import Path
from oras import Oras
#initializations 
owner = sys.argv[1]
target_platform = str (sys.argv[2])
conda_prefix = sys.argv[3]

#create oras object
oras = Oras (owner, conda_prefix, target_platform)

directory = "conda-bld"
location = Path(conda_prefix) / directory / target_platform

#push the all found packages to the registry
for data in location.iterdir():
    strFile = str(data)
    if strFile.endswith('tar.bz2'):
        oras.push(target_platform, data)