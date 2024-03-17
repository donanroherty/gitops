#!/bin/bash
set -e

# Configure the runner
./config.sh --url "${REPO_URL}" --token "${REG_TOKEN}" -pat=${PAT} --unattended --replace

# Start the runner
exec ./run.sh
