#!/usr/bin/env bash
set -xe

## install the runner
if [ -z "$RUNNER_TARBALL_URL" ]; then
  echo "RUNNER_TARBALL_URL is not set"
  exit 1
fi

FILE_NAME="actions-runner.tar.gz"

echo "Setting up GH Actions runner tool cache"
# Required for various */setup-* actions to work, location is also know by various environment
# variable names in the actions/runner software : RUNNER_TOOL_CACHE / RUNNER_TOOLSDIRECTORY / AGENT_TOOLSDIRECTORY
# Warning, not all setup actions support the env vars and so this specific path must be created regardless
RUN_AS_GROUP=$(sudo -i -u "${RUN_AS}" bash -c 'id -gn' 2>/dev/null)
echo "Set file ownership of action runner hosted tools cache"
mkdir -p /opt/hostedtoolcache
chown -R "${RUN_AS}":"$RUN_AS_GROUP" /opt/hostedtoolcache

echo "Creating actions-runner directory for the GH Action installation"
cd /opt/
mkdir -p actions-runner && cd actions-runner


echo "Downloading the GH Action runner from $RUNNER_TARBALL_URL to $FILE_NAME"
curl -o $FILE_NAME -L "$RUNNER_TARBALL_URL"

echo "Un-tar action runner"
tar xzf ./$FILE_NAME
echo "Delete tar file"
rm -rf $FILE_NAME

if [ "${INSTALL_DEPENDENCIES}" = "true" ]; then
    echo "Installing dependencies"
    ./bin/installdependencies.sh
fi

echo "Set file ownership of action runner"
chown -R "${RUN_AS}":"$RUN_AS_GROUP" /opt/actions-runner
