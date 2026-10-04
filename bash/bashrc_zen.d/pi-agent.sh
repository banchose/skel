alias cdpi='cd ~/gitdir/skel/pi'
alias cdpis='cd ~/gitdir/skel/pi/skills'
alias cdmoon='cd ~/temp/moon'
alias cdbills='cd ~/gitdir/configs/pi-dirs/bills'
alias editpi='nvim ~/gitdir/skel/bash/bashrc_zen.d/pi-agent.sh'

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
  docker run --rm -it "${entrypoint_args[@]}" \
    -e WOLFRAM_APP_ID \
    -e FASTMAIL_API_TOKEN \
    -e TOMTOM_API_KEY \
    -e TINFOIL_API_KEY \
    -e OPENROUTER_API_KEY \
    -e EDITOR="nvim" \
    -e ENGRAM_HOME="/home/node/.engram" \
    -e ANTHROPIC_API_KEY \
    -e AWS_BEARER_TOKEN_BEDROCK \
    -e EXA_API_KEY \
    -e LAT \
    -e LON \
    -e OPENWEATHER_APP_ID \
    -e PONYTAIL_DEFAULT_MODE=off \
    -e SHELL=/bin/bash \
    -e TERM \
    -v "$PWD:/workspace" \
    -v "$HOME/gitdir/skel/engram":/home/node/.engram \
    -v pi-agent-home:/home/node/.pi/agent \
    pi-sandbox "$@"
}

alias pi-pic='grim -t jpeg -g "$(slurp -d)" - | tee ./pi-pic-"$(date "+%s").jpg" | wl-copy'

pp() {

  rm ~/gitdir/configs/pi-dirs/bills/pics/*.jpg
  # grim -t jpeg -g "$(slurp -d)" - | tee "$HOME"/gitdir/configs/pi-dirs/bills/pics/pi-pic-"$(date "+%s").jpg" | wl-copy
  grim -t jpeg -g "$(slurp -d)" - | tee "$HOME/gitdir/configs/pi-dirs/bills/pics/pi-pic-one-shot.jpg" | wl-copy

}
