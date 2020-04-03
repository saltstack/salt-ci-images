#!/bin/bash

# Exit on failures
set -e

export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

echo "Update Pyenv"
pyenv update

echo "Install Python ${SALT_PY_VERSION}"
pyenv install -vv ${SALT_PY_VERSION}

echo "Install salt v${SALT_VERSION}"
# Select the instaled Python
pyenv shell ${SALT_PY_VERSION}
# Install Salt
pip install salt==${SALT_VERSION}
