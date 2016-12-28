#!/bin/bash

set -e

export PATH=/node_modules/.bin:$PATH
if [ -f ${WEBPACK_CONFIG} ] && which webpack >/dev/null 2>&1; then
	echo "Running webpack to compile assets."
	webpack --config ${WEBPACK_CONFIG} ${WEBPACK_ARGS:-}
fi
