#!/bin/bash

# Exit on failures
set -e
# Echo what runs
set -x

# Call the main prep file
. os-images/files/prep-uploads.sh

# Prep states
. os-images/Docker/files/prep-states.sh

# Prep pillar
. os-images/Docker/files/prep-pillar.sh
