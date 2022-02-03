#!/bin/bash
mkdir -p build
cd build

if [[ "${FEATURE_STATIC}" == "1" ]]; then
    BUILD_TYPE="-DENABLE_STATIC=ON -DDISABLE_SHARED=ON"
else
    BUILD_TYPE="-DENABLE_STATIC=OFF -DDISABLE_SHARED=OFF"
fi

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DENABLE_CONDA=ON \
      -DMULTI_SEMANTICS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      $BUILD_TYPE \
      ${CMAKE_ARGS} \
      ..

make VERBOSE=1 -j${CPU_COUNT}

make install
