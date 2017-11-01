#!/bin/bash

set -eo pipefail
shopt -s nullglob

if [ $# -eq 0 ]; then
	for x in ${PROJ_ROOT}/docker/pre-deploy.d/*; do
		if [ -x "${x}" ]; then
			echo "-----> Running ${x}"
			"${x}"
		fi
	done
	if [ -f ${PACKAGE_JSON} ] && [ -z "${PROD:-}" ]; then
		NPM_TIMESTAMP_FILE=/node_modules/.timestamp
		if [ ! -f "${NPM_TIMESTAMP_FILE}" ] || [ "${PACKAGE_JSON}" -nt "${NPM_TIMESTAMP_FILE}" ]; then
			# Only run "npm install" again if there has been a change to the package.json.
			echo "Installing dev javascript dependencies defined in ${PACKAGE_JSON} to /node_modules via npm."
			mkdir -p /node_modules
			(cd $(dirname ${PACKAGE_JSON}) && NODE_ENV=development npm install --prefix /)
			touch ${NPM_TIMESTAMP_FILE}
		fi
	fi
	/etc/deploy/run.py
	for x in ${PROJ_ROOT}/docker/post-deploy.d/*; do
		if [ -x "${x}" ]; then
			echo "-----> Running ${x}"
			"${x}"
		fi
	done
	mkdir -p /var/log/supervisor/{cron,nginx,gunicorn}
	if [ -z "${PROD}" -a -f ${WEBPACK_CONFIG} ]; then
		mkdir -p /var/log/supervisor/webpack
	fi
	if [ -n ${READY_FILE} ]; then
		touch ${READY_FILE}
	fi
	exec supervisord -c /etc/supervisord.conf
else
	exec "$@"
fi
