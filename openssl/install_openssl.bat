nmake install
if errorlevel 1 exit 1

:: don't include html docs that get installed
rd /s /q %LIBRARY_PREFIX%\html

REM Install step
rem copy out32dll\openssl.exe %PREFIX%\openssl.exe
rem copy out32\ssleay32.lib %LIBRARY_LIB%\ssleay32_static.lib
rem copy out32\libeay32.lib %LIBRARY_LIB%\libeay32_static.lib
rem copy out32dll\ssleay32.lib %LIBRARY_LIB%\ssleay32.lib
rem copy out32dll\libeay32.lib %LIBRARY_LIB%\libeay32.lib
rem copy out32dll\ssleay32.dll %LIBRARY_BIN%\ssleay32.dll
rem copy out32dll\libeay32.dll %LIBRARY_BIN%\libeay32.dll
rem mkdir %LIBRARY_INC%\openssl
rem xcopy /S inc32\openssl\*.* %LIBRARY_INC%\openssl\
