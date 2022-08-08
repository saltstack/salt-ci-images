#!/usr/bin/env bash

# Exit on failures
set -e
# Echo what runs
set -x

rm -rf /tmp/* || true
find /var/log/ -type f -exec rm -rf {} \;
touch /var/log/lastlog
sync
history -c
