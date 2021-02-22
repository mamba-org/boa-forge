#!/bin/bash
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
export C_INCLUDE_PATH="${PREFIX}/include"

# Legacy toolchain flags
if [[ ${c_compiler} =~ .*toolchain.* ]]; then
    if [ $(uname) == "Darwin" ]; then
        export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib"
        export CC=clang
        export CXX=clang++
    else
        export LDFLAGS="$LDFLAGS -Wl,--disable-new-dtags"
    fi
fi
if [[ ${target_platform} != osx-64 ]]; then
    export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,$PREFIX/lib"
fi

if [[ "${FEATURE_STATIC}" == "1" ]]; then
    BUILD_TYPE="--enable-static --disable-shared"
else
    BUILD_TYPE="--disable-static --enable-shared"
fi

if [[ $target_platform =~ linux.* ]]; then
    USESSL="--with-ssl=${PREFIX}"
else
    USESSL="--with-darwinssl --without-ssl"
fi;

./configure \
    --prefix=${PREFIX} \
    --host=${HOST} \
    ${USESSL} \
    $(feature $FEATURE_LDAP --enable-ldap --disable-ldap) \
    $(feature $FEATURE_KRB5 --with-gssapi=${PREFIX} "") \
    $(feature $FEATURE_HTTP2 --with-nghttp2=${PREFIX} --without-nghttp2) \
    $(feature $FEATURE_ZLIB --with-zlib=${PREFIX} --without-zlib) \
    $(feature $FEATURE_SSH2 --with-libssh2=${PREFIX} --without-libssh2) \
    --with-ca-bundle=${PREFIX}/ssl/cacert.pem \
    ${BUILD_TYPE}

make -j${CPU_COUNT} ${VERBOSE_AT}
make install

# Includes man pages and other miscellaneous.
rm -rf "${PREFIX}/share"
