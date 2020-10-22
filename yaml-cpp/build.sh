#!/bin/bash

mkdir build
cd build

if [[ "${FEATURE_STATIC}" == "1" ]]; then
    BUILD_TYPE="-DYAML_BUILD_SHARED_LIBS=OFF"
else
    BUILD_TYPE="-DYAML_BUILD_SHARED_LIBS=ON"
fi

# Configure step
cmake ${CMAKE_ARGS} ..             \
    -GNinja                        \
    -DBUILD_SHARED_LIBS=ON         \
    $BUILD_TYPE                    \
    -DYAML_CPP_BUILD_TESTS=OFF     \
    -DCMAKE_BUILD_TYPE=Release     \
    -DCMAKE_PREFIX_PATH=$PREFIX    \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \

# Build step
ninja install
