alias cdpi='cd ~/gitdir/skel/pi'
pi-w() {
  cd ~/piland/w || {
    echo "No ~/w"
    return 1
  }
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
  docker run --rm -it "${entrypoint_args[@]}" \
    -e TINFOIL_API_KEY \
    -e ANTHROPIC_API_KEY \
    -e OPENROUTER_API_KEY \
    -e EDITOR="nvim" \
    -e PONYTAIL_DEFAULT_MODE=off \
    -e SHELL=/bin/bash \
    -e TERM \
    -v "$PWD:/workspace" \
    -v pi-agent-home-w:/home/node/.pi/agent \
    pi-sandbox-w "$@"
  #  -e EXA_API_KEY \
}

alias pi-pic='grim -t jpeg -g "$(slurp -d)" - | tee ./pi-pic-"$(date "+%s").jpg" | wl-copy'
