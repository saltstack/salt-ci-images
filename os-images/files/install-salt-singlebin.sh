#!/usr/bin/env bash

# Exit on failures
set -e
# Echo what runs
set -x

SALT_ARCHIVE_NAME=salt-${SALT_VERSION}-linux-amd64.tar.gz
SALT_DOWNLOAD_URL=https://repo.saltproject.io/salt-singlebin/${SALT_VERSION}/${SALT_ARCHIVE_NAME}

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
tar zxvf ${SALT_ARCHIVE_NAME}
chmod +x salt

rm -f ${SALT_ARCHIVE_NAME}
