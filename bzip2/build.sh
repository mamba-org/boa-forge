#!/bin/sh
set -ex

# toolchain flags + bzip flags + fpic
export CFLAGS="${CFLAGS} -Wall -Winline -O2 -g -D_FILE_OFFSET_BITS=64 -fPIC"
USED_CC=${GCC:-${CC}}

if [[ "${FEATURE_STATIC}" == "1" ]]; then
    make install PREFIX=${PREFIX} CFLAGS="${CFLAGS}" CC="${USED_CC}" -j${CPU_COUNT}
else
    make install PREFIX=${PREFIX} CFLAGS="${CFLAGS}" CC="${USED_CC}" -j${CPU_COUNT}
    # build shared library
    if [[ ${target_platform} =~ .*linux.* ]]; then
      make -f Makefile-libbz2_so CFLAGS="${CFLAGS}" CC="${USED_CC}" -j${CPU_COUNT}
      ln -s libbz2.so.${PKG_VERSION} libbz2.so
      cp -d libbz2.so* ${PREFIX}/lib/
    elif [[ ${target_platform} == osx-* ]]; then
      ${USED_CC} -shared -Wl,-install_name -Wl,libbz2.dylib -o libbz2.${PKG_VERSION}.dylib blocksort.o huffman.o crctable.o randtable.o compress.o decompress.o bzlib.o
      cp libbz2.${PKG_VERSION}.dylib ${PREFIX}/lib/
      ln -s libbz2.${PKG_VERSION}.dylib ${PREFIX}/lib/libbz2.dylib
    fi
    rm -rf $PREFIX/lib/libbz2.a
fi

