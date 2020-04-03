#!/bin/bash

# Exit on failures
set -e

export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

echo "Contents of ${SALT_ROOT_DIR}:"
ls -lah ${SALT_ROOT_DIR}

# Select the instaled Python
pyenv shell ${SALT_PY_VERSION}

COMMAND="salt-call --config-dir=${SALT_ROOT_DIR}/conf --local --log-level=info --file-root=${SALT_ROOT_DIR}/states --pillar-root=${SALT_ROOT_DIR}/pillar state.sls ${SALT_STATE} --retcode-passthrough"
echo "Running: ${COMMAND}"
eval "${COMMAND}"
