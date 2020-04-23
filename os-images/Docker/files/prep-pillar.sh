#!/bin/bash

# Exit on failures
set -e
# Echo what runs
set -x

# Call the main pillar prep file
. os-images/files/prep-pillar.sh
