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

if [ -f ${PACKAGE_JSON} ]; then
	# Install the javascript dependencies in /node_modules so that our app
	# can find them easily without having them within our source code base.
	echo "Installing production javascript dependencies defined in ${PACKAGE_JSON} to /node_modules via npm."
	(cd / && npm install --production $(dirname ${PACKAGE_JSON}))
fi

for x in ${APP_ROOT}/docker/post-build.d/*; do
	if [ -x "${x}" ]; then
		echo "----> Running ${x}"
		"${x}"
	fi
done
