#!/bin/bash

set -eo pipefail
shopt -s nullglob

for x in ${PROJ_ROOT}/docker/pre-build.d/*; do
	if [ ! -d "${x}" -a -x "${x}" ]; then
		echo "----> Running ${x}"
		"${x}"
	fi
done

if [ -f ${PROJ_ROOT}/docker/requirements.txt ]; then
	echo "Installing python requirements from ${PROJ_ROOT}/docker/requirements.txt"
	pip install -r ${PROJ_ROOT}/docker/requirements.txt
fi

if [ -f ${PACKAGE_JSON} ]; then
	# Install the javascript dependencies in /node_modules so that our app
	# can find them easily without having them within our source code base.
	echo "Installing production javascript dependencies defined in ${PACKAGE_JSON} to /node_modules via npm."
	mkdir -p /node_modules
	ln -s ${PACKAGE_JSON} /
	(cd $(dirname ${PACKAGE_JSON}) && npm install --production --prefix /)
fi

for x in ${PROJ_ROOT}/docker/post-build.d/*; do
	if [ ! -d "${x}" -a -x "${x}" ]; then
		echo "----> Running ${x}"
		"${x}"
	fi
done
