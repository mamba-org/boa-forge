REM edited from the one from Anaconda
copy %RECIPE_DIR%\CMakeLists.txt CMakeLists.txt

mkdir build
cd build

cmake -G "Ninja" ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D BUILD_SHARED_LIBS=OFF ^
      ..

ninja install --verbose

rem REM Build step
rem nmake -f makefile.msc
rem jom -f makefile.msc lib bzip2
rem if errorlevel 1 exit 1

rem REM fake condition
rem rem IF ("%FEATURE_STATIC%" != "") (
rem 	REM Install step
rem 	copy libbz2.lib %LIBRARY_LIB%\libbz2_static.lib || exit 1
rem 	REM Some packages expect 'bzip2.lib', so make another copy
rem 	copy libbz2.lib %LIBRARY_LIB%\bzip2_static.lib || exit 1
rem 	copy bzlib.h %LIBRARY_INC% || exit 1
rem ) ELSE (
rem 	cl /O2 /Ibzlib.h /Ibzlib_private.h /D_USRDLL /D_WINDLL blocksort.c bzlib.c compress.c crctable.c decompress.c huffman.c randtable.c /LD /Felibbz2.dll /link /DEF:libbz2.def
rem 	if errorlevel 1 exit 1

rem 	copy libbz2.lib %LIBRARY_LIB% || exit 1
rem 	REM Some packages expect 'bzip2.lib', so make copies
rem 	copy libbz2.lib %LIBRARY_LIB%\bzip2.lib || exit 1
rem 	copy libbz2.dll %LIBRARY_BIN% || exit 1
rem 	copy libbz2.dll %LIBRARY_BIN%\bzip2.dll || exit 1
rem )