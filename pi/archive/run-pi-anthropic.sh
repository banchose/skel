#!/usr/bin/env bash

set -euo pipefail

docker run --rm -it \
  -e ANTHROPIC_API_KEY \
  -v "$PWD:/workspace" \
  -v pi-agent-home:/home/node/.pi/agent \
  pi-sandbox
