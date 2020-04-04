#!/bin/bash

# Exit on failures
set -e
# Echo what runs
set -x

rm -rf /tmp/*
find /var/log/ -type f -exec rm -rf {} \;
touch /var/log/lastlog
history -c
