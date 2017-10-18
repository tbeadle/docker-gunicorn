#!/bin/bash

set -eo pipefail

repo=tbeadle/gunicorn-nginx
rev=7

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( 2.7 3.5 3.6 )
fi

for ver in "${versions[@]}"; do
	docker build -t ${repo}:${ver}-r${rev} -f Dockerfile.${ver} .
	docker tag ${repo}:${ver}-r${rev} ${repo}:${ver}
	docker build -t ${repo}:${ver}-r${rev}-onbuild -f Dockerfile.${ver}-onbuild .
	docker tag ${repo}:${ver}-r${rev}-onbuild ${repo}:${ver}-onbuild
done
echo "To push the images, run:"
for ver in "${versions[@]}"; do
	echo "docker push ${repo}:${ver}-r${rev}"
	echo "docker push ${repo}:${ver}"
	echo "docker push ${repo}:${ver}-r${rev}-onbuild"
	echo "docker push ${repo}:${ver}-onbuild"
done
