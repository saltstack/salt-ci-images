#!/bin/bash -

source /root/.nvm/nvm.sh
nvm install 0.10
nvm use 0.10
npm install -g coffee-script
npm install .
