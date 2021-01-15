if "%ARCH%"=="32" (
    set OSSL_CONFIGURE=VC-WIN32
) ELSE (
    set OSSL_CONFIGURE=VC-WIN64A
)

REM Configure step
%LIBRARY_BIN%\perl configure %OSSL_CONFIGURE% --prefix=%LIBRARY_PREFIX% --openssldir=%LIBRARY_PREFIX%
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

if not exist "%LIBRARY_LIB%" mkdir %LIBRARY_LIB%
copy libcrypto_static.lib %LIBRARY_LIB%\libcrypto_static.lib
copy libssl_static.lib %LIBRARY_LIB%\libssl_static.lib
