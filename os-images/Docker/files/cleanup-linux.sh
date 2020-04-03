#!/bin/bash

find /var/log/ -type f -exec rm -rf {} \;
touch /var/log/lastlog
