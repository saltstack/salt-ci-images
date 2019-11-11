#!/bin/bash

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# Clone State Tree
. ${dir}/prep-minion-conf.sh
. ${dir}/prep-states.sh
. ${dir}/prep-pillar.sh

echo "Copying gitpython.sls to the temp states directory"
cp ${dir}/gitpython.sls .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/states/
echo "Copying noop.sls to the temp states directory"
cp ${dir}/noop.sls .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/states/
ls -lah .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/states
