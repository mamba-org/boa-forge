mkdir -p build-cpp; cd build-cpp
rm -rf CMakeCache.txt

if [[ "${FEATURE_STATIC}" == "1" ]]; then
    BUILD_TYPE="-DBUILD_SHARED_LIBS=OFF"
else
    BUILD_TYPE="-DBUILD_SHARED_LIBS=ON"
fi

cmake .. \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DREPROC++=ON \
      ${BUILD_TYPE}

make install -j${CPU_COUNT}
