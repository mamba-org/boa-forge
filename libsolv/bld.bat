set "CFLAGS= -MD"
echo %CFLAGS%

set "CXXFLAGS= -MD"
echo %CXXFLAGS%

mkdir build
cd build

cmake -G "Ninja" ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_VERBOSE_MAKEFILE=ON ^
      -D ENABLE_CONDA=ON ^
      -D MULTI_SEMANTICS=ON ^
      -D WITHOUT_COOKIEOPEN=ON ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D DISABLE_SHARED=OFF ^
      ..
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

cd ..
mkdir static_build
cd static_build

cmake -G "Ninja" ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_VERBOSE_MAKEFILE=ON ^
      -D ENABLE_CONDA=ON ^
      -D MULTI_SEMANTICS=ON ^
      -D WITHOUT_COOKIEOPEN=ON ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D ENABLE_STATIC=ON ^
      -D DISABLE_SHARED=ON ^
      ..

if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1