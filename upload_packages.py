import sys
from pathlib import Path
from oras import Oras
#initializations 
owner = sys.argv[1]
target_platform = str (sys.arg[2])
conda_prefix = sys.arg[3]

oras = Oras (owner, conda_prefix)

directory = "conda-bld"
location = Path(conda_prefix) / directory / target_platform


for data in location.iterdir():
    strFile = str(data)
    if strFile.endswith('tar.bz2'):
        oras.push(target_platform, data)