:: copy files which are missing from the release tarball
:: see: https://github.com/libssh2/libssh2/issues/379
:: TODO: remove this in the 1.9.1 or later releases
copy %RECIPE_DIR%\missing_files\*.c tests\

set PATH=%PREFIX%\cmake-bin\bin;%PATH%

mkdir build_static && cd build_static
:: Build static libraries
cmake -GNinja ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D BUILD_SHARED_LIBS=OFF ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -D ENABLE_ZLIB_COMPRESSION=ON ^
    -D BUILD_EXAMPLES=OFF ^
    -D BUILD_TESTING=OFF ^
	%SRC_DIR%
IF %ERRORLEVEL% NEQ 0 exit 1

ninja install
IF %ERRORLEVEL% NEQ 0 exit 1

rem cd ..
rem mkdir build_shared && cd build_shared

rem :: Build shared libraries
rem cmake -GNinja ^
rem     -D CMAKE_BUILD_TYPE=Release ^
rem     -D BUILD_SHARED_LIBS=ON ^
rem     -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
rem     -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
rem     -D ENABLE_ZLIB_COMPRESSION=ON ^
rem     -D BUILD_EXAMPLES=OFF ^
rem     -D BUILD_TESTING=OFF ^
rem 	%SRC_DIR%
rem IF %ERRORLEVEL% NEQ 0 exit 1

rem ninja
rem IF %ERRORLEVEL% NEQ 0 exit 1
rem ninja install
rem IF %ERRORLEVEL% NEQ 0 exit 1
