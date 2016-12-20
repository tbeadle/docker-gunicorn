#!/bin/bash

set -eo pipefail
shopt -s nullglob

for x in ${APP_ROOT}/docker/pre-build.d/*; do
	if [ -x "${x}" ]; then
		echo "----> Running ${x}"
		"${x}"
	fi
done

if [ -f ${APP_ROOT}/docker/requirements.txt ]; then
	echo "Installing python requirements from ${APP_ROOT}/docker/requirements.txt"
	pip install -r ${APP_ROOT}/docker/requirements.txt
fi

for x in ${APP_ROOT}/docker/post-build.d/*; do
	if [ -x "${x}" ]; then
		echo "----> Running ${x}"
		"${x}"
	fi
done
