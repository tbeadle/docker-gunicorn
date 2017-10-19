#!/usr/bin/env bash

set -eo pipefail

install -v -d -m 0755 -o ${WWW_USER} -g ${WWW_GROUP} $(eval echo ~${WWW_USER})
