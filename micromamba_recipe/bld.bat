mkdir build
cd build

cmake .. ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_BUILD_TYPE="Release" ^
    -D BUILD_EXE=ON ^
    -D BUILD_STATIC=ON ^
    -D BUILD_SHARED=OFF ^
    -D STATIC_DEPENDENCIES=ON ^
    -D BUILD_BINDINGS=OFF ^
    -G "Ninja"

ninja install --verbose
