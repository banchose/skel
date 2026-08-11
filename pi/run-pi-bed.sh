#!/usr/bin/env bash

set -euo pipefail

# if [[ -d ~/temp ]]; then
#   cd ~/temp
# else
#   echo "~/temp does not exist"
# fi

ENTRYPOINT_ARGS=()
if [[ "${1:-}" == "-b" ]]; then
  ENTRYPOINT_ARGS=(--entrypoint bash)
fi

docker run --rm -it \
  "${ENTRYPOINT_ARGS[@]}" \
  -e AWS_BEARER_TOKEN_BEDROCK \
  -e EXA_API_KEY \
  -e LAT \
  -e LON \
  -e OPENWEATHER_APP_ID \
  -v "$PWD:/workspace" \
  -v pi-agent-home:/home/node/.pi/agent \
  pi-sandbox
