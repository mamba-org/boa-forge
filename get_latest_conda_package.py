import glob
import sys

folder = sys.argv[1]
mms = glob.glob(f'{folder}/micromamba*')

versions = []
for m in mms:
    m = m[:-len('.tar.bz2')]  # remove tar.bz2 ending
    name, version, build = m.rsplit('-', 2)
    build_num = int(build.rsplit('_', 1)[-1])
    versions.append((name, version, build_num, build))

def assemble_file(v):
    return f"{v[0]}-{v[1]}-{v[3]}.tar.bz2"

print(assemble_file(max(versions)))
