mkdir build
cd build

cmake .. ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_BUILD_TYPE="Release" ^
    -D BUILD_LIBMAMBA=ON ^
    -D BUILD_STATIC_DEPS=ON ^
    -D BUILD_MICROMAMBA=ON ^
    -D MICROMAMBA_LINKAGE=FULL_STATIC ^
    -G "Ninja"

ninja install --verbose
