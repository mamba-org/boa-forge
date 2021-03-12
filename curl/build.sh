#!/bin/bash

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* .

# need macosx-version-min flags set in cflags and not cppflags
export CFLAGS="$CFLAGS $CPPFLAGS"

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
