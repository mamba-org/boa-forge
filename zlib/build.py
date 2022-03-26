# from bitfurnace.autotools import Autotools

# class Recipe(Autotools):

# 	def get_configure_args(self):
# 		return self.configure_args + ["--static"]

# 	def __init__(self):
# 		self.cflags += ['-fPIC']
# 		self.cxxflags += ['-fPIC']

from bitfurnace.cmake import CMake
import pathlib

def safe_unlink(p):
	assert(prefix in p.parents)
	p.unlink()

def rm(path):
	if isinstance(path, pathlib.PurePath):
		safe_unlink(path)
	else:
		for p in path:
			safe_unlink(p)

class Recipe(CMake):

	def post_install(self):
		if target_platform.startswith('win'):
			(library_lib / "zlib.lib").unlink()
			(library_bin / "zlib.dll").unlink()
		else:
			print(features)
			if not features.static:
				# delete the .a library
				rm(prefix / "lib" / "libz.a")
			else:
				rm((prefix / "lib").glob("libz*.dylib"))

	def __init__(self):
		print("Activated features: ", features)

		if target_platform.startswith('win'):
			self.cmake_args["CMAKE_C_FLAGS_RELEASE"] = "/MT /O2 /Ob2 /DNDEBUG"
		self.cflags += ['-fPIC']
		self.cxxflags += ['-fPIC']

