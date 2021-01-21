if "%ARCH%"=="32" (
    set OSSL_CONFIGURE=VC-WIN32
) ELSE (
    set OSSL_CONFIGURE=VC-WIN64A
)

REM Configure step
%LIBRARY_BIN%\perl configure %OSSL_CONFIGURE% ^
	--prefix=%LIBRARY_PREFIX% ^
	--openssldir=%LIBRARY_PREFIX% ^
	enable-static-engine ^
    enable-capieng ^
	no-ssl2 ^
    no-tests ^
    -utf-8 ^
    no-shared


if errorlevel 1 exit 1

REM Build step
rem if "%ARCH%"=="64" (
rem     ml64 -c -Foms\uptable.obj ms\uptable.asm
rem     if errorlevel 1 exit 1
rem )

nmake install
if errorlevel 1 exit 1

rem nmake -f ms\nt.mak
rem if errorlevel 1 exit 1
rem nmake -f ms\ntdll.mak
rem if errorlevel 1 exit 1

rem nmake test
if errorlevel 1 exit 1

del %LIBRARY_LIB%\libcrypto.lib
del %LIBRARY_LIB%\libssl.lib

del %LIBRARY_BIN%\libcrypto.dll
del %LIBRARY_BIN%\libssl.dll

del %LIBRARY_BIN%\libcrypto-1_1-x64.dll
del %LIBRARY_BIN%\libcrypto-1_1-x64.pdb
del %LIBRARY_BIN%\libssl-1_1-x64.pdb
del %LIBRARY_BIN%\libssl-1_1-x64.pdb

if not exist "%LIBRARY_LIB%" mkdir %LIBRARY_LIB%
copy libcrypto.lib %LIBRARY_LIB%\libcrypto_static.lib
copy libssl.lib %LIBRARY_LIB%\libssl_static.lib
