#!/usr/bin/env bash

# Exit on failures
set -e
# Echo what runs
set -x

export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

echo "Install Python ${SALT_PY_VERSION}"
pyenv install -vv ${SALT_PY_VERSION}

echo "Install salt v${SALT_VERSION}"
# Select the installed Python
pyenv shell ${SALT_PY_VERSION}
# Install Salt
if [ "${SALT_VERSION}" == "master" ]
then
  pip install git+https://github.com/saltstack/salt.git@master
else
  pip install salt==${SALT_VERSION}
fi
