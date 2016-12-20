#!/usr/bin/env bash

set -eo pipefail

echo "Building python ${PYTHON_VERSION}"

mkdir -p ${BUILD_ROOT}/python

echo "Getting python tarball"
wget -O ${BUILD_ROOT}/python.tar.gz https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz

echo "Building python"
tar -xC ${BUILD_ROOT}/python --strip-components=1 -f ${BUILD_ROOT}/python.tar.gz
cd ${BUILD_ROOT}/python

CONFIG_ARGS="--prefix=${INSTALL_ROOT} \
    --enable-ipv6 --with-dbmliborder=bdb:gdbm --with-system-expat \
    --with-system-ffi --with-fpectl --enable-shared"

./configure ${CONFIG_ARGS}
make -j 2
make install

find $INSTALL_ROOT/lib \
	\( -type d -and -name test -or -name tests \) -or \
	\( -type f -and -name '*.pyc' -or -name '*.pyo' \) | \
	xargs rm -rf

cd ${INSTALL_ROOT}/bin

case "${PYTHON_VERSION}" in
    3.*)
        ln -s python3 python
        ;;
esac
ldconfig
