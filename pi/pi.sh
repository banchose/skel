#!/usr/bin/env bash
# source this file, then run: pi-bed [-b] [pi args...]

pi-bed() {
  if ! docker info >/dev/null 2>&1; then
    echo "docker daemon is not running" >&2
    return 1
  fi

  local entrypoint_args=()
  if [[ "${1:-}" == "-b" ]]; then
    entrypoint_args=(--entrypoint bash)
    shift
  fi

  docker run --rm -it \
    "${entrypoint_args[@]}" \
    -e AWS_BEARER_TOKEN_BEDROCK \
    -e EXA_API_KEY \
    -e LAT \
    -e LON \
    -e OPENWEATHER_APP_ID \
    -v "$PWD:/workspace" \
    -v pi-agent-home:/home/node/.pi/agent \
    pi-sandbox "$@"
}
