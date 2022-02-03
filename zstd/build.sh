#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -O3 -fPIC"

# # Fix undefined clock_gettime (Is this needed? See above)
# if [[ ${target_platform} =~ linux.* ]]; then
#   export LDFLAGS="${LDFLAGS} -lrt"
# fi

# declare -a _CMAKE_EXTRA_CONFIG

# if [[ ${HOST} =~ .*darwin.* ]]; then
#   if [[ ${_XCODE_BUILD} == yes ]]; then
#       CMAKE_GENERATOR="Xcode"
#       _CMAKE_EXTRA_CONFIG+=(-DCMAKE_OSX_ARCHITECTURES=x86_64)
#       _CMAKE_EXTRA_CONFIG+=(-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT})
#       _VERBOSE=""
#   fi
#   unset MACOSX_DEPLOYMENT_TARGET
#   export MACOSX_DEPLOYMENT_TARGET
#   _CMAKE_EXTRA_CONFIG+=(-DCMAKE_AR=${AR})
#   _CMAKE_EXTRA_CONFIG+=(-DCMAKE_RANLIB=${RANLIB})
#   _CMAKE_EXTRA_CONFIG+=(-DCMAKE_LINKER=${LD})
# fi

# if [[ ${HOST} =~ .*linux.* ]]; then
#   # I hate you so much CMake.
#   LIBPTHREAD=$(find ${PREFIX} -name "libpthread.so")
#   _CMAKE_EXTRA_CONFIG+=(-DPTHREAD_LIBRARY=${LIBPTHREAD})
#   LIBRT=$(find ${PREFIX} -name "librt.so")
#   _CMAKE_EXTRA_CONFIG+=(-DRT_LIBRARIES=${LIBRT})
# fi

pushd build/cmake

if [[ "$FEATURE_STATIC" == "1" ]]; then
  STATIC_ARGS="-DZSTD_BUILD_STATIC=ON -DZSTD_BUILD_SHARED=OFF -DZSTD_BUILD_TESTS=1"
else
  STATIC_ARGS="-DZSTD_BUILD_STATIC=OFF -DZSTD_BUILD_SHARED=ON -DZSTD_BUILD_TESTS=0"
fi;

# FULL_AR=`which ${AR}`
#      -DCMAKE_AR=${FULL_AR}              \
cmake -G"${CMAKE_GENERATOR}"             \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DCMAKE_INSTALL_LIBDIR="lib"       \
      -DCMAKE_PREFIX_PATH="${PREFIX}"    \
      -DZSTD_LEGACY_SUPPORT=1            \
      -DZSTD_BUILD_PROGRAMS=0            \
      -DZSTD_BUILD_CONTRIB=0             \
      -DZSTD_PROGRAMS_LINK_SHARED=ON     \
      ${STATIC_ARGS}                     \
      "${_CMAKE_EXTRA_CONFIG[@]}"

make -j${CPU_COUNT} install
# make test
popd
