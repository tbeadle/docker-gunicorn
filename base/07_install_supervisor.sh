#!/usr/bin/env bash

set -eo pipefail

echo "Installing supervisor ${SUPERVISOR_VERSION}."
pip2 install --no-cache-dir -U supervisor==${SUPERVISOR_VERSION}
