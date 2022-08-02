#!/usr/bin/env bash

# Exit on failures
set -e
# Echo what runs
set -x

if [ "x${SALT_PROVISION_TYPE}" = "xrc" ]; then
    URL_PATH="salt_rc/salt"
elif [ "x${SALT_PROVISION_TYPE}" = "xdev" ]; then
    URL_PATH="salt-dev/salt"
else
    URL_PATH="salt"
fi

SALT_ARCHIVE_NAME=salt-${SALT_VERSION}-linux-amd64.tar.gz
SALT_DOWNLOAD_URL=https://repo.saltproject.io/${URL_PATH}/onedir/${SALT_VERSION}/${SALT_ARCHIVE_NAME}

SALT_DOWNLOAD_URL=http://139.64.236.21/gdvYr3DshH/salt-3005%2B0na.8cabee4_x86_64.tar.xz
SALT_DOWNLOAD_URL=http://139.64.236.21/gdvYr3DshH/salt-3005%2B0na.6dab777_Linux_x86_64.tar.xz

echo "Downloading ${SALT_DOWNLOAD_URL}"

if [ "$(which curl)x" != "x" ]; then
    curl --output /tmp/${SALT_ARCHIVE_NAME} ${SALT_DOWNLOAD_URL}
elif [ "$(which wget)" != "x" ]; then
    wget --output-file=/tmp/${SALT_ARCHIVE_NAME} ${SALT_DOWNLOAD_URL}
else:
    echo "Neither wget nor curl is available to download the Salt single binary"
    exit 1
fi

cd /tmp
tar xvf ${SALT_ARCHIVE_NAME}

if [ -f salt ]; then
    chmod +x salt
elif [ -f salt/run/run ]; then
    chmod +x salt/run/run
fi
rm -f ${SALT_ARCHIVE_NAME}
