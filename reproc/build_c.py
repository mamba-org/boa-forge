from cmake import CMake

class Recipe(CMake):
	cmake_configure_args = {
		'BUILD_SHARED_LIBS': not features.static
	}