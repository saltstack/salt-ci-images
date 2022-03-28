#!/usr/bin/env bash

# Exit on failures
set -e
# Echo what runs
set -x

echo "Contents of ${SALT_ROOT_DIR}:"
ls -lah ${SALT_ROOT_DIR}

if [ -f /tmp/salt ]; then
    SALT_CALL="/tmp/salt call"
else
    SALT_CALL="salt-call"
fi

COMMAND="${SALT_CALL} --config-dir=${SALT_ROOT_DIR}/conf --local --log-level=info --file-root=${SALT_ROOT_DIR}/states --pillar-root=${SALT_ROOT_DIR}/pillar state.sls ${SALT_STATE} --retcode-passthrough"
echo "Running: ${COMMAND}"
if [ -f /tmp/salt ]; then
    eval "${COMMAND}"
else
    eval "~/.pyenv/versions/${SALT_PY_VERSION}/bin/${COMMAND}"
fi
