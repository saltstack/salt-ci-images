#!/bin/bash

# Exit on failures
set -e
# Echo what runs
set -x

PILLAR_DIR=".tmp/${DISTRO_SLUG}/pillar"
export PILLAR_DIR

echo "Building Pillar Tree At ${PILLAR_DIR}"

if [ -d ${PILLAR_DIR} ]; then
    rm -rf ${PILLAR_DIR}
fi

mkdir -p ${PILLAR_DIR}
cp pillar-tree/*.sls ${PILLAR_DIR}/

echo "Pillar Tree Contents:"
ls -lah ${PILLAR_DIR}/
