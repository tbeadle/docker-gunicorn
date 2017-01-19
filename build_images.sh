#!/bin/bash

REPO=tbeadle/gunicorn-nginx

for VER in 3.6 3.5 2.7; do
	docker build -t ${REPO}:${VER} -f Dockerfile.${VER} .
	docker build -t ${REPO}:${VER}-onbuild -f Dockerfile.${VER}-onbuild .
done
