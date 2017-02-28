#!/bin/bash

set -eo pipefail

echo "Installing dependencies for building:"
echo "    nginx ${NGINX_VERSION}"
echo "    python ${PYTHON_VERSION}"
echo "    gunicorn ${GUNICORN_VERSION}"
echo "    supervisor ${SUPERVISOR_VERSION}"
echo "    node ${NODE_VERSION}"
echo "    npm ${NPM_VERSION}"
echo ""
apt-get update

apt-get install -y --no-install-recommends \
	ca-certificates \
	cron \
	gcc \
	libpcre3-dev \
	libexpat1-dev \
	libffi-dev \
	libssl-dev \
	locales \
	make \
	mime-support \
	vim \
	wget \
	xz-utils \


# Supervisord doesn't currently support running under python3,
# so we'll install python2.7 just for that if using 3.x for our app.
case ${PYTHON_VERSION} in
    3.*)
        apt-get install -y --no-install-recommends python2.7
	;;
esac

rm -r /var/lib/apt/lists/* /etc/cron.*/*
