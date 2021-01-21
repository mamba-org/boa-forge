pushd "%SRC_DIR%"\build\cmake
cmake -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR="lib" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DZSTD_BUILD_SHARED=OFF ^
    -DZSTD_USE_STATIC_RUNTIME=ON

if errorlevel 1 exit 1
ninja install --verbose
if errorlevel 1 exit 1
dir
dir lib

rem copy lib\zstd.dll  %PREFIX%\Library\bin\zstd.dll
rem if errorlevel 1 exit 1
rem copy %PREFIX%\Library\bin\zstd.dll %PREFIX%\Library\bin\libzstd.dll
rem if errorlevel 1 exit 1
rem copy %PREFIX%\Library\lib\zstd.lib %PREFIX%\Library\lib\libzstd.lib
rem if errorlevel 1 exit 1
