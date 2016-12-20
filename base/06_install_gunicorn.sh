#!/usr/bin/env bash

set -eo pipefail

echo "Installing gunicorn ${GUNICORN_VERSION}."

pip install --no-cache-dir -U gunicorn==${GUNICORN_VERSION}
