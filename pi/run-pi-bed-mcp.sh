#!/usr/bin/env bash

set -euo pipefail

docker run --rm -it \
  -e AWS_BEARER_TOKEN_BEDROCK \
  -e EXA_API_KEY \
  -v "$PWD:/workspace" \
  -v "$HOME"/.config/mcp/mcp.json:/home/node/.config/mcp/.mcp.json \
  -v pi-agent-home:/home/node/.pi/agent \
  pi-sandbox
