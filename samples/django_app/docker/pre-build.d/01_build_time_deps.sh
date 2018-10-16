#!/bin/bash

set -eo pipefail

echo "Installing build time dependencies."
apt-get update
apt-get install -y --no-install-recommends libpq-dev postgresql-client-9.6
rm -r /var/lib/apt/lists/*
