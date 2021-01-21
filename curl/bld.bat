mkdir build

cmake -GNinja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DBUILD_SHARED_LIBS=OFF ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -DCMAKE_USE_SCHANNEL=ON ^
      -DCMAKE_USE_LIBSSH2=OFF ^
      -DUSE_ZLIB=ON ^
      -DCURL_STATIC_CRT=ON ^
      %SRC_DIR%

IF %ERRORLEVEL% NEQ 0 exit 1

ninja install --verbose

REM This is implicitly using WinSSL.  See Makefile.vc for more info.
rem nmake /f Makefile.vc MODE=dll VC=%VS_MAJOR:"=% WITH_DEVEL=%LIBRARY_PREFIX% ^
rem          WITH_ZLIB=dll WITH_SSH2=dll DEBUG=no ENABLE_IDN=no ENABLE_SSPI=yes ^
rem          MACHINE=%ARCH_STRING%
rem if errorlevel 1 exit 1

REM WITH_SSH2=static
REM This is implicitly using WinSSL.  See Makefile.vc for more info.
rem nmake /f Makefile.vc mode=static VC=%VS_MAJOR:"=% WITH_DEVEL=%LIBRARY_PREFIX% ^
rem          WITH_ZLIB=static DEBUG=no ENABLE_IDN=no ENABLE_SSPI=yes ^
rem          MACHINE=%ARCH_STRING%
rem if errorlevel 1 exit 1

rem REM install static library
rem robocopy ..\builds\libcurl-vc%VS_MAJOR:"=%-%ARCH_STRING%-release-static-zlib-static-ipv6-sspi-schannel\ %LIBRARY_PREFIX% *.* /E
rem if %ERRORLEVEL% GTR 3 exit 1

rem REM install everything else
rem robocopy ..\builds\libcurl-vc%VS_MAJOR:"=%-%ARCH_STRING%-release-dll-zlib-dll-ssh2-dll-ipv6-sspi-winssl\ %LIBRARY_PREFIX% *.* /E
rem if %ERRORLEVEL% GTR 3 exit 1