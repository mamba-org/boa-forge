#!/bin/bash
set -x
autoreconf -vfi
mkdir build-${HOST} && pushd build-${HOST}

if [[ "${FEATURE_STATIC}" == "1" ]]; then
    BUILD_TYPE="--enable-static --disable-shared"
else
    BUILD_TYPE="--disable-static --enable-shared"
fi

if [ "$(uname)" == "Darwin" ]; then
    WITH_ICONV="--with-iconv"
else
    WITH_ICONV="--without-iconv"
fi

${SRC_DIR}/configure --prefix=${PREFIX} ${BUILD_TYPE}                             \
                     $(feature $FEATURE_ZLIB --with-zlib --without-zlib)          \
                     $(feature $FEATURE_BZIP2 --with-bz2lib --without-bz2lib)     \
                     $(feature $FEATURE_LZ4 --with-lz4 --without-lz4)             \
                     $(feature $FEATURE_XZ --with-lzma --without-lzma)            \
                     $(feature $FEATURE_LZO --with-lzo2 --without-lzo2)           \
                     $(feature $FEATURE_ZSTD --with-zstd --without-zstd)          \
                     $(feature $FEATURE_OPENSSL --with-openssl --without-openssl) \
                     --without-cng                                                \
                     --without-nettle                                             \
                     $(feature $FEATURE_XML2 --with-xml2 --without-xml2)          \
                     --without-expat                                              \
                     $WITH_ICONV

make -j${CPU_COUNT} ${VERBOSE_AT}
make install
