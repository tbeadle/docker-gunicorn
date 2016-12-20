#!/bin/bash

echo "Installing 4096-bit dhparam.pem"
mkdir -p /etc/nginx/ssl/
install -m 0644 -o root -g root $(dirname $0)/data/dhparam.pem /etc/nginx/ssl/dhparam.pem
