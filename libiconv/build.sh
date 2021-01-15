#!/usr/bin/env sh
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./build-aux
cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./libcharset/build-aux
set -ex

if [[ "${FEATURE_STATIC}" == "1" ]]; then
    BUILD_TYPE="--enable-static --disable-shared"
else
    BUILD_TYPE="--disable-static --enable-shared"
fi

./configure --prefix=${PREFIX}  \
            --host=${HOST}      \
            --build=${BUILD}    \
            ${BUILD_TYPE}       \
            --disable-rpath

make -j${CPU_COUNT} ${VERBOSE_AT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check
fi
make install

# TODO :: Only provide a static iconv executable for GNU/Linux.
# TODO :: glibc has iconv built-in. I am only providing it here
# TODO :: for legacy packages (and through gritted teeth).
if [[ ${HOST} =~ .*linux.* ]]; then
  chmod 755 ${PREFIX}/lib/libiconv.so.2.6.1
  chmod 755 ${PREFIX}/lib/libcharset.so.1.0.0
  if [ -f ${PREFIX}/lib/preloadable_libiconv.so ]; then
    chmod 755 ${PREFIX}/lib/preloadable_libiconv.so
  fi
fi

# remove libtool files
find $PREFIX -name '*.la' -delete
