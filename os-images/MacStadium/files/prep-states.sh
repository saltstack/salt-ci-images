#!/bin/bash

echo "Building Minimal State Tree"
if [ -d .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/states ]; then
    rm -rf .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/states
fi
mkdir -p .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/states
git clone https://github.com/saltstack/salt-jenkins.git -b ${SALT_BRANCH} .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/states
if test -n "${SALT_PR}"
then
    (cd .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/states ; git fetch origin "pull/${SALT_PR}/head")
    (cd .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/states ; git checkout FETCH_HEAD)
fi
(cd .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/states ; git log -1)
rm -rf .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/states/.git

printf "noop:\n  test.succeed_without_changes" > .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/states/empty.sls
