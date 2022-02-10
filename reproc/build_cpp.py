from cmake import CMake

class Recipe(CMake):
    cmake_configure_args = {
        'BUILD_SHARED_LIBS': not features.static,
        'REPROC++': True
    }

    def pre_configure(self):
        if (self.workdir / "CMakeCache.txt").exists():
            (self.workdir / "CMakeCache.txt").unlink()