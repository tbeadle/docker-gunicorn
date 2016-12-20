#!/bin/bash

set -eo pipefail
shopt -s nullglob

for x in $(dirname $0)/[[:digit:]]*; do
	if [ -x ${x} ]; then
		${x}
	else
		echo "WARNING: ${x} is not executable!"
	fi
done
