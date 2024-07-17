#!/bin/bash

# @dev
# This bash script setups the needed artifacts to use
# the @benddao/bend-v2 package as source of deployment
# scripts for testing or coverage purposes.

echo "[BASH] Setting up environment"

source .env

export GIT_COMMIT_HASH=`git rev-parse HEAD | cast to-bytes32`

echo $ETHERSCAN_KEY
echo $GIT_COMMIT_HASH

echo "[BASH] environment ready"