# https://aider.chat/docs/install.html
# https://github.com/Aider-AI/aider
# python -m pip install aider-install
# aider-install

aider_run() {
  aider --model sonnet --api-key anthropic="${ANTHROPIC_API_KEY}"
}

aider_help() {

  cat <<EOF
aider --dark-mode
.aider.conf.yml: dark-mode: true

export AIDER_DARK_MODE=true
.env: AIDER_DARK_MODE=true
aider --model claude-sonnet-4-6 --api-key anthropic=$ANTHROPIC_API_KEY 
See: ~/.aider.conf.yml
EOF
}

aider-help() {
  local aider_help_path="${HOME}/gitdir/skel/aider/Aider-opus-notes.md"
  local pager

  if command -v bat >/dev/null 2>&1; then
    pager=bat
  elif command -v less >/dev/null 2>&1; then
    pager=less
  elif command -v cat >/dev/null 2>&1; then
    pager=cat
  else
    printf >&2 'aider-help: no usable pager found (bat/less/cat)\n'
    return 1
  fi

  if [[ ! -f "${aider_help_path}" ]]; then
    printf >&2 'aider-help: cannot find %s\n' "${aider_help_path}"
    return 1
  fi

  "${pager}" "${aider_help_path}"
}
