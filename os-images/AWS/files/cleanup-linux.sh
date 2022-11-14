#!/usr/bin/env bash

# Exit on failures
set -e
# Echo what runs
set -x

mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

mkdir -p /home/${SSH_USERNAME}/.ssh
chmod 700 /home/${SSH_USERNAME}/.ssh
echo > /home/${SSH_USERNAME}/.ssh/authorized_keys
chmod 600 /home/${SSH_USERNAME}/.ssh/authorized_keys
chown -R ${SSH_USERNAME} /home/${SSH_USERNAME}/.ssh

rm -rf /tmp/* || true

# journalctl
if command -v journalctl; then
    journalctl --rotate || true
    journalctl --vacuum-time=1s || true
fi

# delete all .gz and rotated file
find /var/log -type f -regex ".*\.gz$" -delete
find /var/log -type f -regex ".*\.[0-9]$" -delete
find /var/log/ -type f -exec rm -rf {} \;
touch /var/log/lastlog
sync
history -c
