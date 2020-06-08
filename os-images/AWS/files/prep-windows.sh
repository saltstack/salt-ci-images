#!/usr/bin/env bash

# Exit on failures
set -e
# Echo what runs
set -x

# Call the main linux prep file
. os-images/files/prep-uploads.sh

# Prep states
. os-images/AWS/files/prep-states.sh

# Prep pillar
. os-images/AWS/files/prep-pillar.sh
