#!/bin/bash

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

. ${dir}/prep-minion-conf.sh
. ${dir}/prep-states.sh
. ${dir}/prep-pillar.sh
printf "    - windows\n" >> .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/pillar/top.sls
if [ "$PY_VERSION" -eq 2 ]; then
    PYTHON_DIR="C:\\Python27"
elif [ "$PY_VERSION" -eq 3 ]; then
    PYTHON_DIR="C:\\Python35"
else
    echo "Don't know how to handle PY_VERSION $PY_VERSION"
    exit 1
fi
printf "python_install_dir: ${PYTHON_DIR}\n" > .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/pillar/windows.sls
printf "virtualenv_path: ${PYTHON_DIR}\\Scripts\\pip.exe\n" >> .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/pillar/windows.sls
