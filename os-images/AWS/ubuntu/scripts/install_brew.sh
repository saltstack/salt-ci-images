#!/bin/bash

# Exit on failures
set -e
# Echo what runs
set -x

if [[ "$(uname -m)" != 'x86_64' ]]; then
  echo "brew won't be installed for $(uname -m) architecture"
  exit 0
fi

echo "====> Installing homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
