#!/bin/bash

mkdir build && cd build

if [[ "${FEATURE_STATIC}" == "1" ]]; then
  BUILD_OPTIONS="-DCARES_STATIC=ON -DCARES_SHARED=OFF -DCARES_BUILD_TOOLS=OFF"
else
  BUILD_OPTIONS="-DCARES_STATIC=OFF -DCARES_SHARED=ON -DCARES_BUILD_TOOLS=ON"
fi

cmake ${CMAKE_ARGS} -G"$CMAKE_GENERATOR" \
      -DCMAKE_BUILD_TYPE=Release         \
      -DCMAKE_INSTALL_PREFIX="$PREFIX"   \
      $BUILD_OPTIONS                     \
      -DCARES_INSTALL=ON                 \
      -DCMAKE_INSTALL_LIBDIR=lib         \
      -GNinja                            \
      ${SRC_DIR}

ninja install
