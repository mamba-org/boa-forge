import glob
import sys
import tarfile

archs = ["linux-64", "osx-64", "win-64"]
folder = "~/micromamba_pkgs/{arch}/"

def get_version_file(folder):
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

	return assemble_file(max(versions)), v[1]

for arch in archs:
	version, pkg_file = get_version_file(folder.format(arch))
	print(f"::set-output name={arch.replace('-', '_')}_pkg::{pkg_file}")
	if arch == "linux-64":
		print(f"::set-output name=micromamba_version::{version}")

	os.makedirs(f"/tmp/micromamba-{arch}")
	with tarfile.open(pkg_file, "r:bz2") as f:
		f.extractall(f"/tmp/micromamba-{arch}/")
