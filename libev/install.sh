#!/usr/bin/env bash

if [[ "$PKG_NAME" != *-libevent ]]; then
	rm "${PREFIX}/include/event.h"
fi
