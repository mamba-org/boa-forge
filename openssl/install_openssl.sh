#!/bin/bash

PERL=${PREFIX}/bin/perl
make install_sw install_ssldirs

# https://github.com/ContinuumIO/anaconda-issues/issues/6424
if [[ ${HOST} =~ .*linux.* ]]; then
  if execstack -q "${PREFIX}"/lib/libcrypto.so.1.1 | grep -e '^X '; then
    echo "Error, executable stack found in libcrypto.so.1.1"
    exit 1
  fi
fi

# remove the static libraries
rm ${PREFIX}/lib/libcrypto.a
rm ${PREFIX}/lib/libssl.a

