#!/usr/bin/env bash

set -euo pipefail

cd /tmp
docker run --rm -it \
  -e AWS_BEARER_TOKEN_BEDROCK \
  -v "$PWD:/workspace" \
  -v pi-agent-home:/home/node/.pi/agent \
  pi-sandbox
cd -
