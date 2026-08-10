#!/usr/bin/env bash

set -euo pipefail

if [[ -d ~/temp ]]; then
  cd ~/temp
else
  echo "~/temp does not exist"
fi

docker run --rm -it \
  -e AWS_BEARER_TOKEN_BEDROCK \
  -e EXA_API_KEY \
  -v "$PWD:/workspace" \
  -v pi-agent-home:/home/node/.pi/agent \
  pi-sandbox
