from cmake import CMake

class Recipe(CMake):
    cmakelists_dir = src_dir / "build" / "cmake"
    workdir = src_dir / "cmake_build"

    cmake_configure_args = {
        'ZSTD_LEGACY_SUPPORT': True,
        'ZSTD_BUILD_PROGRAMS': False,
        'ZSTD_BUILD_CONTRIB': False,
        'ZSTD_PROGRAMS_LINK_SHARED': True   
    }
