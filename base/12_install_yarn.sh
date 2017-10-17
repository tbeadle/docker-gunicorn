#!/bin/bash

set -eo pipefail

echo "Installing yarn v${YARN_VERSION}"
npm install -g yarn@${YARN_VERSION}
