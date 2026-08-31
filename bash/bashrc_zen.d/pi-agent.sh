alias cdpi='cd ~/gitdir/skel/pi'
pi-bed() {
  if ! docker info >/dev/null 2>&1; then
    echo "docker daemon is not running" 1>&2
    return 1
  fi
  local entrypoint_args=()
  if [[ "${1:-}" == "-b" ]]; then
    entrypoint_args=(--entrypoint bash)
    shift
  elif [[ "${1:-}" == "-u" ]]; then
    entrypoint_args=(-u 0 --entrypoint bash)
    shift
  fi
  docker run --rm -it "${entrypoint_args[@]}" -e EDITOR="nvim" -e ANTHROPIC_API_KEY -e AWS_BEARER_TOKEN_BEDROCK -e EXA_API_KEY -e LAT -e LON -e OPENWEATHER_APP_ID -e SHELL=/bin/bash -e TINFOIL_API_KEY -v "$PWD:/workspace" -v pi-agent-home:/home/node/.pi/agent pi-sandbox "$@"
}
