import glob
import sys
import tarfile
import os
from os.path import expanduser
import stat
from shutil import copyfile
# Python program to find SHA256 hash string of a file
import hashlib

pkg_name = sys.argv[1]

def sha256(fn):
    sha256_hash = hashlib.sha256()
    with open(fn, "rb") as f:
        # Read and update hash string value in blocks of 4K
        for byte_block in iter(lambda: f.read(4096),b""):
            sha256_hash.update(byte_block)
        with open(fn + ".sha256", "w") as fo:
            fo.write(sha256_hash.hexdigest())

archs = ["linux-64", "osx-64", "win-64"]
folder = "~/Downloads/{arch}/"

def get_version_file(folder, pkg_name="micromamba"):
    mms = glob.glob(expanduser(f'{folder}/{pkg_name}*'))
    print("Folder: ", folder)
    print(mms)
    versions = []
    for m in mms:
        m = m[:-len('.tar.bz2')]  # remove tar.bz2 ending

        fpath, version, build = m.rsplit('-', 2)

        if os.path.basename(fpath) != pkg_name:
            continue

        build_num = int(build.rsplit('_', 1)[-1])
        versions.append((fpath, version, build_num, build))

    def assemble_file(v):
        return f"{v[0]}-{v[1]}-{v[3]}.tar.bz2"

    v = max(versions)

    print(assemble_file(v))

    return assemble_file(v), v[1]

for arch in archs:
    pkg_file, version = get_version_file(folder.format(arch=arch), pkg_name)
    print(f"::set-output name={arch.replace('-', '_')}_pkg::{pkg_file}")
    if arch == "linux-64":
        print(f"::set-output name=micromamba_version::{version}")

    os.makedirs(f"/tmp/micromamba-{arch}", exist_ok=True)
    with tarfile.open(pkg_file, "r:bz2") as f:
        f.extractall(f"/tmp/micromamba-{arch}/")

for arch in archs:
    os.makedirs(f"/tmp/micromamba-bins/{arch}/", exist_ok=True)
    if arch.startswith("win"):
        outfile = f"/tmp/micromamba-bins/micromamba-{arch}.exe"
        copyfile(f"/tmp/micromamba-{arch}/Library/bin/micromamba.exe", outfile)
    else:
        outfile = f"/tmp/micromamba-bins/micromamba-{arch}"
        copyfile(f"/tmp/micromamba-{arch}/bin/micromamba", outfile)
        st = os.stat(outfile)
        os.chmod(outfile, st.st_mode | stat.S_IEXEC)

    sha256(outfile)

    print(f"::set-output name=micromamba_bin_{arch.replace('-', '_')}::{outfile}")
    print(f"::set-output name=micromamba_sha_{arch.replace('-', '_')}::{outfile}.sha256")