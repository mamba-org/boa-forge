mkdir build
cd build

rem -DYAML_BUILD_SHARED_LIBS=ON ^

REM Configure step
cmake .. ^
    -GNinja ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DYAML_BUILD_SHARED_LIBS=OFF ^
    -DYAML_CPP_BUILD_TESTS=OFF ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	-DYAML_MSVC_SHARED_RT=OFF

if errorlevel 1 exit 1

REM Build step
ninja install --verbose
if errorlevel 1 exit 1
