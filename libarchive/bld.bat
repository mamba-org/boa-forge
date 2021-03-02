:: Needed so we can find stdint.h from msinttypes.
set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

:: VS2008 doesn't have stdbool.h so copy in our own
:: to 'lib' where the other headers are so it gets picked up.
if "%VS_MAJOR%" == "9" (
  if "%ARCH%" == "64" (
::  The Windows 6.0A SDK does not provide the bcrypt.lib for 64-bit:
::  C:\Program Files\Microsoft SDKs\Windows\v6.0A\Lib\x64
::  .. yet does for 32-bit, oh well, this may disable password protected zip support.
::  https://social.msdn.microsoft.com/Forums/windowsdesktop/en-US/673cc344-430c-4510-96e8-80b0bb42ae11/can-not-link-bcryptlib-to-an-64bit-build?forum=windowssdk
    set ENABLE_CNG=NO
  ) else (
    set ENABLE_CNG=YES
::  Have decided to standardise on *not* using bcrypt instead. If we update to the Windows Server 2008 SDK we could revisit this
    set ENABLE_CNG=NO
  )
)

if "%vc%" NEQ "9" goto not_vc9
:: This does not work yet:
:: usage: cl [ option... ] filename... [ /link linkoption... ]
  set USE_C99_WRAP=no
  copy %LIBRARY_INC%\inttypes.h src\common\inttypes.h
  copy %LIBRARY_INC%\stdint.h src\common\stdint.h
  goto endit
:not_vc9
  set USE_C99_WRAP=no
:endit

if exist CMakeCache.txt goto build
if "%USE_C99_WRAP%" NEQ "yes" goto skip_c99_wrap
set COMPILER=-DCMAKE_C_COMPILER=c99-to-c89-cmake-nmake-wrap.bat
set C99_TO_C89_WRAP_DEBUG_LEVEL=1
set C99_TO_C89_WRAP_SAVE_TEMPS=1
set C99_TO_C89_WRAP_NO_LINE_DIRECTIVES=1
set C99_TO_C89_CONV_DEBUG_LEVEL=1
:skip_c99_wrap
:: set cflags because NDEBUG is set in Release configuration, which errors out in test suite due to no assert

cmake -G "Ninja" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      %COMPILER% ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS:BOOL=FALSE ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /Ob2 /DNDEBUG" ^
      -DCMAKE_CXX_FLAGS_RELEASE="/MT /O2 /Ob2 /DNDEBUG" ^
      -DENABLE_BZip2=ON ^
      -DENABLE_ZSTD=ON ^
      -DENABLE_ZLIB=ON ^
      -DENABLE_LZMA=OFF ^
      -DENABLE_LIBB2=OFF ^
      -DENABLE_LZ4=OFF ^
      -DENABLE_LZO=OFF ^
      -DENABLE_LIBXML2=OFF ^
      -DENABLE_EXPAT=OFF ^
      -DENABLE_PCREPOSIX=OFF ^
      -DENABLE_LibGCC=OFF ^
      -DENABLE_CNG=OFF ^
      -DENABLE_ICONV=OFF ^
      .

:build

:: Build.
:: jom -j%CPU_COUNT% VERBOSE=1
ninja -j%CPU_COUNT% -v
if errorlevel 1 exit /b 1
ninja install
if errorlevel 1 exit /b 1