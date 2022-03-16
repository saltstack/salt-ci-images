#!/usr/bin/env bash

# Exit on failures
set -e
# Echo what runs
set -x

# Check if in container
# https://stackoverflow.com/questions/52065842/python-docker-ascii-codec-cant-encode-character
if [ -f /.dockerenv ]; then
    echo "Running in container!"
    IS_CENTOS7=$(echo $(cat /etc/*ease* | grep '^NAME=\|^VERSION=') | grep CentOS | grep 7 || true)
    if [[ -z $IS_CENTOS7 ]]; then
        echo "Container is NOT running CentOS 7."
        echo "Updating env var: C.UTF-8"
        export LANG=C.UTF-8
    else
        # CentOS7 doesn't have C.UTF-8; must use en_US.utf8
        echo "Container IS running CentOS 7."
        echo "Updating env var: LANG=en_US.utf8"
        export LANG=en_US.utf8
    fi
fi

export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

echo "Install Python ${SALT_PY_VERSION}"
pyenv install -vv ${SALT_PY_VERSION}

echo "Install salt v${SALT_VERSION}"
# Select the installed Python
pyenv shell ${SALT_PY_VERSION}
pip install -U pip setuptools wheel
# Install Salt
pip install git+https://github.com/garethgreenaway/salt.git@kitchen_docker_test
#if [ "${SALT_VERSION}" == "master" ]
#then
#  #pip install git+https://github.com/saltstack/salt.git@master
#else
#  pip install salt==${SALT_VERSION}
#fi
