#!/bin/bash

# Call the main pillar prep file
. os-images/files/prep-pillar.sh

# Tweak it some more
printf "py$PY_VERSION: true\n" >> ${PILLAR_DIR}/base.sls
