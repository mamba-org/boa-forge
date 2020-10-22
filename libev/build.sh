# Get an updated config.sub and config.guess


if [[ "${FEATURE_STATIC}" == "1" ]]; then
    BUILD_TYPE="--enable-static --disable-shared"
else
    BUILD_TYPE="--disable-static --enable-shared"
fi

cp $BUILD_PREFIX/share/libtool/build-aux/config.* .
./configure --prefix="${PREFIX}" $BUILD_TYPE
make

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check
fi

make install