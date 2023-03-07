#!/usr/bin/env bash

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
cp golden-pillar-tree/*.sls ${PILLAR_DIR}/

if [ "${INSTALL_GITHUB_ACTIONS_RUNNER}" == "yes" ]; then
    echo "github_actions_runner: true" >> ${PILLAR_DIR}/base.sls
    echo "github_actions_runner_tarball_url: '${GITHUB_ACTIONS_RUNNER_TARBALL_URL}'" >> ${PILLAR_DIR}/base.sls
    echo "github_actions_runner_install_dependencies: ${INSTALL_GITHUB_ACTIONS_RUNNER_DEPENDENCIES}" >> ${PILLAR_DIR}/base.sls
else
    echo "github_actions_runner: false" >> ${PILLAR_DIR}/base.sls
fi

echo "ssh_username: ${SSH_USERNAME}" >> ${PILLAR_DIR}/base.sls

echo "Pillar Tree Contents:"
ls -lah ${PILLAR_DIR}/
