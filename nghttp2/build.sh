#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* .

if [[ "${FEATURE_STATIC}" == "1" ]]; then
    BUILD_TYPE="--enable-static --disable-shared --enable-lib-only"
else
    BUILD_TYPE="--disable-static --enable-shared"
fi

./configure --prefix=${PREFIX} --enable-python-bindings=no $BUILD_TYPE

make -j${CPU_COUNT} ${VERBOSE_AT}

make install