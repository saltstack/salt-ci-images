#!/bin/bash

# Exit on failures
set -e
# Echo what runs
set -x

# Call the main linux prep file
. os-images/files/prep-uploads.sh

# Prep states
. os-images/MacStadium/files/prep-states.sh

# Prep pillar
. os-images/MacStadium/files/prep-pillar.sh
