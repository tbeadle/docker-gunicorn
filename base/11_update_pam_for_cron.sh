#!/bin/bash

set -eo pipefail

# See http://stackoverflow.com/questions/21926465/issues-running-cron-in-docker-on-different-hosts
echo "Disabling pam_loginuid PAM module for cron."
sed -i 's/\(.*\)\(pam_loginuid\.so\)/#\1\2/' /etc/pam.d/cron
