#!/bin/bash

# copy files which are missing from the release tarball
# see: https://github.com/libssh2/libssh2/issues/379
# TODO: remove this in the 1.9.1 or later releases
cp ${RECIPE_DIR}/missing_files/*.c tests/

# We use a repackaged cmake from elsewhere to break a build cycle.
export PATH=${PREFIX}/cmake-bin/bin:${PATH}

mkdir build && cd build

if [[ "${FEATURE_STATIC}" == "1" ]]; then
    BUILD_TYPE="-D BUILD_SHARED_LIBS=OFF"
else
    BUILD_TYPE="-D BUILD_SHARED_LIBS=ON"
fi

cmake ${CMAKE_ARGS} 					 \
	  -D CMAKE_INSTALL_PREFIX=$PREFIX 	 \
      -D CMAKE_PREFIX_PATH=$PREFIX 		 \
      $BUILD_TYPE 						 \
      -D CRYPTO_BACKEND=OpenSSL 		 \
      -D CMAKE_INSTALL_LIBDIR=lib 		 \
      -D ENABLE_ZLIB_COMPRESSION=ON 	 \
      -D CMAKE_INSTALL_RPATH=$PREFIX/lib \
      $SRC_DIR

make -j${CPU_COUNT}
# ctest  # fails on the docker image
make install
