#!/bin/bash

sudo find /var/log/ -type f -exec rm -rf {} \;
sudo touch /var/log/lastlog
