set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%;%RECIPE_DIR%

mkdir build
cd build
:: Configure.
cmake -G "Ninja" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /Ob2 /DNDEBUG" ^
      %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
ninja install --verbose
if errorlevel 1 exit 1

:: Test.
rem ctest
if errorlevel 1 exit 1


del %LIBRARY_LIB%\zlib.lib
del %LIBRARY_BIN%\zlib.dll

:: Some OSS libraries are happier if z.lib exists, even though it's not typical on Windows.
rem copy %LIBRARY_LIB%\zlib.lib %LIBRARY_LIB%\z.lib || exit 1

:: Qt in particular goes looking for this one (as of 4.8.7).
rem copy %LIBRARY_LIB%\zlib.lib %LIBRARY_LIB%\zdll.lib || exit 1

:: Copy license file to the source directory so conda-build can find it.
rem copy %RECIPE_DIR%\license.txt %SRC_DIR%\license.txt || exit 1
