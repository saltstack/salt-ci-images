#!/usr/bin/env bash

# Exit on failures
set -e
# Echo what runs
set -x

echo "Contents of ${SALT_ROOT_DIR}:"
ls -lah ${SALT_ROOT_DIR}

if [ -f /tmp/salt ]; then
    SALT_CALL="/tmp/salt call"
elif [ -f /tmp/salt/run/run ]; then
    SALT_CALL="/tmp/salt/run/run call"
elif [ -f /tmp/salt/salt-call ]; then
    SALT_CALL=/tmp/salt/salt-call
else
    SALT_CALL="salt-call"
fi

COMMAND="${SALT_CALL} --config-dir=${SALT_ROOT_DIR}/conf --local --log-level=debug --file-root=${SALT_ROOT_DIR}/states --pillar-root=${SALT_ROOT_DIR}/pillar state.sls ${SALT_STATE} --retcode-passthrough"
echo "Running: ${COMMAND}"
if [ -f /tmp/salt ]; then
    # Singlebin
    eval "${COMMAND}"
elif [ -f /tmp/salt/run/run ]; then
    # Onedir
    eval "${COMMAND}"
elif [ -f /tmp/salt/salt-call ]; then
    eval "${COMMAND}"
else
    # Pyenv
    eval "~/.pyenv/versions/${SALT_PY_VERSION}/bin/${COMMAND}"
fi
