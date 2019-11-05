#!/bin/bash

# Call the main pillar prep file
. ../../files/prep-pillar.sh

# Tweak it some more
printf "py$PY_VERSION: true\n" > ${PILLAR_DIR}/base.sls
printf "install_metrics: false\n" >> ${PILLAR_DIR}/base.sls
