#!/usr/bin/env bash

# Exit on failures
set -e
# Echo what runs
set -x

echo "Contents of ${SALT_ROOT_DIR}:"
ls -lah ${SALT_ROOT_DIR}

if [ -f /tmp/salt/bin/salt-call ]; then
    SALT_CALL=/tmp/salt/bin/salt-call
else
    echo "Could not find a Salt mayflower build or Salt install in a PyEnv environment"
    exit 1
fi

printf "\n\nSystem Grains Information:\n"
GRAINS_COMMAND="${SALT_CALL} --config-dir=${SALT_ROOT_DIR}/conf --local --grains && sleep 1; printf '\n\n'; "
echo "Running: ${GRAINS_COMMAND}"
eval "${GRAINS_COMMAND}"

COMMAND="${SALT_CALL} --config-dir=${SALT_ROOT_DIR}/conf --local --log-level=debug --file-root=${SALT_ROOT_DIR}/states --pillar-root=${SALT_ROOT_DIR}/pillar state.sls ${SALT_STATE} --retcode-passthrough"
echo "Running: ${COMMAND}"
eval "${COMMAND}"
