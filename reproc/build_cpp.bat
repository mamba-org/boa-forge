mkdir build-cpp
cd build-cpp
del CMakeCache.txt

IF not x%PKG_NAME:static=%==x%PKG_NAME% (
    set BUILD_TYPE=-DBUILD_SHARED_LIBS=OFF
) ELSE (
    set BUILD_TYPE=-DBUILD_SHARED_LIBS=ON
)


cmake .. ^
      -G "Ninja" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -DCMAKE_INSTALL_LIBDIR=lib ^
      -DREPROC_TEST=OFF ^
      -DREPROC_EXAMPLES=OFF ^
      -DREPROC++=ON ^
      -DBUILD_SHARED_LIBS=OFF ^
      -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreaded" ^
      %BUILD_TYPE%

rem ninja test
ninja install  --verbose

rem IF not x%PKG_NAME:static=%==x%PKG_NAME% (
rem     REN %LIBRARY_PREFIX%\lib\reproc++.lib reproc++_static.lib
rem )