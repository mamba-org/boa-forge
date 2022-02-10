# TODO?!
# autoreconf -vfi
# cp $BUILD_PREFIX/share/gnuconfig/config.* .
export PYTHONPATH="${PYTHONPATH}:/Users/wolfvollprecht/Programs/bitfurnace"
python3 ~/Programs/bitfurnace/bitfurnace/runner.py $RECIPE_DIR/build.py

# if [[ "${FEATURE_STATIC}" == "1" ]]; then
#     BUILD_TYPE="--enable-static --disable-shared"
# else
#     BUILD_TYPE="--disable-static --enable-shared"
# fi

# ./configure --prefix=${PREFIX}  \
#             --build=${BUILD}    \
#             --host=${HOST}		\
#             ${BUILD_TYPE}

# make -j${CPU_COUNT} ${VERBOSE_AT}

# if [[ "$CONDA_BUILD_CROSS_COMPILATION" != 1 ]]; then
#   make check
# fi

# make install
