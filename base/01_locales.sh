#!/usr/bin/env bash

set -eo pipefail

echo "Setting up locale."
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
