#!/bin/bash

autoreconf -vfi

if [[ "${FEATURE_STATIC}" == "1" ]]; then
    BUILD_TYPE="--enable-static --disable-shared"
else
    BUILD_TYPE="--disable-static --enable-shared"
fi

./configure --prefix=${PREFIX}  \
            --build=${BUILD}    \
            --host=${HOST}		\
            ${BUILD_TYPE}

make -j${CPU_COUNT} ${VERBOSE_AT}

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != 1 ]]; then
  make check
fi

make install
