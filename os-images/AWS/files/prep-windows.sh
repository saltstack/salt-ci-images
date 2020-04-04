#!/bin/bash

# Exit on failures
set -e
# Echo what runs
set -x

# Call the main linux prep file
. os-images/files/prep-uploads.sh
cp os-images/files/windows-roots.conf ${DISTRO_TMP_DIR}/

# Prep states
. os-images/AWS/files/prep-states.sh

# Prep pillar
. os-images/AWS/files/prep-pillar.sh
