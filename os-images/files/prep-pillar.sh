#!/bin/bash

PILLAR_DIR=".tmp/${DISTRO_SLUG}/${SALT_BRANCH}/pillar"
echo "Building Pillar Data for Python Version: ${PY_VERSION}"
if [ -d ${PILLAR_DIR} ]; then
    rm -rf ${PILLAR_DIR}
fi
export PILLAR_DIR

mkdir -p ${PILLAR_DIR}
cp pillar-tree/*.sls ${PILLAR_DIR}/
