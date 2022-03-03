#!/bin/bash

# Exit on failures
set -e
# Echo what runs
set -x

# This will be used later by the Salt tests to skip any tests
# that shouldn't run in Docker containers.
echo "export ON_DOCKER=1" > /etc/profile.d/on_docker.sh

# Call the main prep file
. os-images/files/prep-uploads.sh

# Prep states
. os-images/Docker/files/prep-states.sh

# Prep pillar
. os-images/Docker/files/prep-pillar.sh
