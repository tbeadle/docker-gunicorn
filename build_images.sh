#!/bin/bash

set -eo pipefail

repo=tbeadle/gunicorn-nginx
rev=1

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( 2.7 3.5 3.6 )
fi

for ver in "${versions[@]}"; do
	docker build -t ${repo}:${ver}-r${rev} -f Dockerfile.${ver} .
	docker build -t ${repo}:${ver}-r${rev}-onbuild -f Dockerfile.${ver}-onbuild .
done
