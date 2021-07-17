mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
         -DCMAKE_INSTALL_PREFIX=${PREFIX} \
         -DCMAKE_BUILD_TYPE="Release" \
         -DBUILD_EXE=ON \
         -DBUILD_BINDINGS=OFF \
         -DBUILD_STATIC=ON \
         -DBUILD_SHARED=OFF \
         -DSTATIC_DEPENDENCIES=ON

make -j${CPU_COUNT}
make install

${STRIP:-strip} ${PREFIX}/bin/micromamba
