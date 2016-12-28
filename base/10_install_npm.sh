#!/bin/bash

set -eo pipefail

echo "Installing node.js v${NODE_VERSION}"
wget -O - https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz | tar -xJvf - -C ${INSTALL_ROOT} --strip-components=1

echo "Upgrading npm to v${NPM_VERSION}"
npm install npm@${NPM_VERSION} -g
