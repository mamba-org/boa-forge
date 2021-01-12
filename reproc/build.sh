mkdir -p build; cd build

if [[ "${FEATURE_STATIC}" == "1" ]]; then
    BUILD_TYPE="-DBUILD_SHARED_LIBS=OFF"
else
    BUILD_TYPE="-DBUILD_SHARED_LIBS=ON"
fi

cmake .. \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      ${BUILD_TYPE}

make install -j${CPU_COUNT}