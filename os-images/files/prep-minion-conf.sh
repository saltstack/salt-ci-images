#!/bin/bash
echo "Generating Minion Config To Upload"
if [ -d .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/conf ]; then
    rm -rf .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/conf
fi
mkdir -p .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/conf

printf "id: packer-local-minion\n" > .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/conf/minion
printf "minion_id_caching: True\n" >> .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/conf/minion
#printf "fileserver_backend:\n  - roots\n  - gitfs\n" >> .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/conf/minion
#printf "gitfs_base: ${SALT_BRANCH}\n" >> .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/conf/minion
#printf "gitfs_remotes:\n  - https://github.com/saltstack/salt-jenkins.git\n" >> .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/conf/minion
# Disable the old windows repo
#printf "winrepo_remotes: []\n" >> .tmp/${DISTRO_SLUG}/${SALT_BRANCH}/conf/minion
