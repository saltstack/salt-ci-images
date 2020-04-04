#!/bin/bash

# Exit on failures
set -e
# Echo what runs
set -x

rm -rf ${SALT_ROOT_DIR}
rm -rf ~/.pyenv
rm -rf ~/.cache/pip

# While we don't have kitchen-salt 0.6.1 out, fake an installed salt-call binary
echo "Creating bogus salt-call binary until kitchen-salt 0.6.1 is out"
echo "#!/bin/bash" > /bin/salt-call
echo "echo \"salt-call ${SALT_VERSION}\"" >> /bin/salt-call
chmod +x /bin/salt-call
