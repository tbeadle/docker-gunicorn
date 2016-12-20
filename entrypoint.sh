#!/bin/bash

set -eo pipefail
shopt -s nullglob

if [ $# -eq 0 ]; then
	for x in ${APP_ROOT}/docker/pre_deploy.d/*; do
		if [ -x "${x}" ]; then
			echo "-----> Running ${x}"
			"${x}"
		fi
	done
	/etc/deploy/run.py
	for x in ${APP_ROOT}/docker/post_deploy.d/*; do
		if [ -x "${x}" ]; then
			echo "-----> Running ${x}"
			"${x}"
		fi
	done
	mkdir -p /var/log/supervisor/{cron,nginx,gunicorn}
	exec supervisord -c /etc/supervisord.conf
else
	exec "$@"
fi
