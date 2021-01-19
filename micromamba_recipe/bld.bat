copy /Y %RECIPE_DIR%\CMakeLists.txt .\src\micromamba\CMakeLists.txt

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
    -D USE_VENDORED_CLI11=ON ^
    -G "Ninja"

ninja install
