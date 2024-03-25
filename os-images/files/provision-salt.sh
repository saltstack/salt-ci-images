#!/usr/bin/env bash

# Exit on failures
set -e
# Echo what runs
set -x

if [ "$(uname)" = "Linux" ]; then
    PLATFORM="linux"
else
    PLATFORM="macos"
fi

if [ "${OS_ARCH}" = "aarch64" ]; then
    SALT_ARCH="arm64"
else
    SALT_ARCH="${OS_ARCH}"
fi

# SALT_MAJOR_VERSION=$(echo "${SALT_VERSION}" | cut -f1 -d'.')
SALT_ARCHIVE_NAME="salt-${SALT_VERSION}-onedir-${PLATFORM}-${SALT_ARCH}.tar.xz"
SALT_DOWNLOAD_URL="https://repo.saltproject.io/salt/py3/onedir/minor/${SALT_VERSION}/${SALT_ARCHIVE_NAME}"

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
