#!/usr/bin/env bash

# Exit on failures
set -e
# Echo what runs
set -x

rm -rf ${SALT_ROOT_DIR}
rm -rf ~/.pyenv
rm -rf ~/.cache/pip
