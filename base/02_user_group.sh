#!/usr/bin/env bash

set -eo pipefail

if ! getent group ${WWW_GROUP}; then
	echo "Adding ${WWW_GROUP} group"
	groupadd ${WWW_GROUP}
fi
if ! getent passwd ${WWW_USER}; then
	echo "Adding ${WWW_USER} user"
	adduser --disabled-password --gecos "www user" -g ${WWW_GROUP} \
		--home /dev/null ${WWW_USER}
fi
