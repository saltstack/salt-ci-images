#!/bin/bash

STATE_DIR=".tmp/${DISTRO_SLUG}/${SALT_BRANCH}/states"
export STATE_DIR

echo "Building State Tree At ${STATE_DIR}"
if [ -d ${STATE_DIR} ]; then
    rm -rf ${STATE_DIR}
fi
mkdir -p ${STATE_DIR}

cp -Rp state-tree/* ${STATE_DIR}/

echo "State Tree Contents:"
ls -lah ${STATE_DIR}/
