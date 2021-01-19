set "CFLAGS= -MD"
echo %CFLAGS%

set "CXXFLAGS= -MD"
echo %CXXFLAGS%

mkdir build
cd build

rem cmake -G "Ninja" ^
rem       -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
rem       -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
rem       -D CMAKE_VERBOSE_MAKEFILE=ON ^
rem       -D ENABLE_CONDA=ON ^
rem       -D MULTI_SEMANTICS=ON ^
rem       -D WITHOUT_COOKIEOPEN=ON ^
rem       -D CMAKE_BUILD_TYPE=Release ^
rem       -D DISABLE_SHARED=OFF ^
rem       ..
rem if errorlevel 1 exit 1

rem ninja
rem if errorlevel 1 exit 1

rem ninja install
rem if errorlevel 1 exit 1

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

ninja install
if errorlevel 1 exit 1