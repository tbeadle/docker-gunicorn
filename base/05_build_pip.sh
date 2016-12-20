#!/usr/bin/env bash

set -eo pipefail

echo "Installing pip."

wget -O - https://bootstrap.pypa.io/get-pip.py | python

case ${PYTHON_VERSION} in
    3.*)
        # Install pip for our python2.7 installation so that supervisord can
        # be installed for it.
        wget -O - https://bootstrap.pypa.io/get-pip.py | python2.7
	rm /usr/local/bin/pip
	ln -s pip3 /usr/local/bin/pip
        ;;
esac
