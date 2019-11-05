#!/bin/bash

if [ -z "${DISTRO_SLUG}" ]; then
    echo "The DISTRO_SLUG env variable is not set"
    exit 1
fi

if [ -z "${SALT_BRANCH}" ]; then
    echo "The SALT_BRANCH env variable is not set"
    exit 1
fi

THIS_FILE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "${THIS_FILE_DIR}/../../.." && pwd)
export REPO_ROOT

echo "REPO ROOT: ${REPO_ROOT}"
cd $REPO_ROOT

DISTRO_TMP_DIR="${REPO_ROOT}/.tmp/${DISTRO_SLUG}/${SALT_BRANCH}"
export DISTRO_TMP_DIR

if [ -d ${DISTRO_TMP_DIR} ]; then
    rm -rf ${DISTRO_TMP_DIR}
fi

mkdir -p ${DISTRO_TMP_DIR}

cp os-images/files/minion ${DISTRO_TMP_DIR}/
