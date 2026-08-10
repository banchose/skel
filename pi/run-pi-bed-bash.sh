#!/usr/bin/env bash

set -euo pipefail

docker run --rm -it \
  -e AWS_BEARER_TOKEN_BEDROCK \
  -e EXA_API_KEY \
  -v "$PWD:/workspace" \
  -v pi-agent-home:/home/node/.pi/agent \
  --build-arg UID="$(id -u)" \
  --build-arg GID="$(id -g)" \
  --entrypoint bash \
  pi-sandbox
