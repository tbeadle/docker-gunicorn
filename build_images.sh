#!/bin/bash

repo=tbeadle/gunicorn-nginx

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( 2.7 3.5 3.6 )
fi

for ver in "${versions[@]}"; do
	docker build -t ${repo}:${ver} -f Dockerfile.${ver} .
	docker build -t ${repo}:${ver}-onbuild -f Dockerfile.${ver}-onbuild .
done
