mkdir build
cd build

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY=1"

cmake ${CMAKE_ARGS} .. \
         -GNinja \
         -DCMAKE_INSTALL_PREFIX=${PREFIX} \
         -DCMAKE_BUILD_TYPE="Release" \
         -DBUILD_LIBMAMBA=ON \
         -DBUILD_STATIC_DEPS=ON \
         -DBUILD_MICROMAMBA=ON \
         -DMICROMAMBA_LINKAGE=FULL_STATIC

ninja

ninja install

# remove everything related to `libmamba`
rm -rf $PREFIX/lib/libmamba*
rm -rf $PREFIX/include/mamba
rm -rf $PREFIX/lib/cmake/libmamba

${STRIP:-strip} ${PREFIX}/bin/micromamba

if [[ "$target_platform" == "osx-"* ]]; then
  ${OTOOL:-otool} -l ${PREFIX}/bin/micromamba
fi
