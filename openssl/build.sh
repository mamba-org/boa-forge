#!/bin/bash

PERL=${PREFIX}/bin/perl
declare -a _CONFIG_OPTS
_CONFIG_OPTS+=(--prefix=${PREFIX})
_CONFIG_OPTS+=(--libdir=lib)
_CONFIG_OPTS+=(shared)
_CONFIG_OPTS+=(threads)
_CONFIG_OPTS+=(enable-ssl2)
_CONFIG_OPTS+=(no-zlib)

# We are cross-compiling or using a specific compiler.
# do not allow config to make any guesses based on uname.
_CONFIGURATOR="perl ./Configure"
case "$target_platform" in
  linux-32)
    _CONFIG_OPTS+=(linux-generic32)
    CFLAGS="${CFLAGS} -Wa,--noexecstack"
    ;;
  linux-64)
    _CONFIG_OPTS+=(linux-x86_64)
    CFLAGS="${CFLAGS} -Wa,--noexecstack"
    ;;
  linux-aarch64)
    _CONFIG_OPTS+=(linux-aarch64)
    CFLAGS="${CFLAGS} -Wa,--noexecstack"
    ;;
  linux-ppc64le)
    _CONFIG_OPTS+=(linux-ppc64le)
    CFLAGS="${CFLAGS} -Wa,--noexecstack"
    ;;
  osx-64)
    _CONFIG_OPTS+=(darwin64-x86_64-cc)
    ;;
  osx-arm64)
    _CONFIG_OPTS+=(darwin64-arm64-cc)
    ;;
esac

CC=${CC}" ${CPPFLAGS} ${CFLAGS}" \
  ${_CONFIGURATOR} ${_CONFIG_OPTS[@]} ${LDFLAGS}

# This is not working yet. It may be important if we want to perform a parallel build
# as enabled by openssl-1.0.2d-parallel-build.patch where the dependency info is old.
# makedepend is a tool from xorg, but it seems to be little more than a wrapper for
# '${CC} -M', so my plan is to replace it with that, or add a package for it? This
# tool uses xorg headers (and maybe libraries) which is unfortunate.
# http://stackoverflow.com/questions/6362705/replacing-makedepend-with-cc-mm
# echo "echo \$*" > "${SRC_DIR}"/makedepend
# echo "${CC} -M $(echo \"\$*\" | sed s'# --##g')" >> "${SRC_DIR}"/makedepend
# chmod +x "${SRC_DIR}"/makedepend
# PATH=${SRC_DIR}:${PATH} make -j1 depend

# make -j${CPU_COUNT} ${VERBOSE_AT}
make -j${CPU_COUNT}

# expected error: https://github.com/openssl/openssl/issues/6953
#    OK to ignore: https://github.com/openssl/openssl/issues/6953#issuecomment-415428340
rm test/recipes/04-test_err.t

# When testing this via QEMU, even though it ends printing:
# "ALL TESTS SUCCESSFUL."
# .. it exits with a failure code.
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  make test > testsuite.log 2>&1 || true
  if ! cat testsuite.log | grep -i "all tests successful"; then
    echo "Testsuite failed!  See $(pwd)/testsuite.log for more info."
    exit 1
  fi
fi
