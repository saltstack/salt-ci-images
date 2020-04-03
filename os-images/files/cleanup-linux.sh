#!/bin/bash

rm -rf /tmp/*
find /var/log/ -type f -exec rm -rf {} \;
touch /var/log/lastlog
history -c
