# Minimal FZF configuration that just loads the basics
#
# Check if fzf is installed, exit if not
type fzf &>/dev/null || {
  echo "fzf not found. Skipping fzf configuration."
  return 0
}

alias prev='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'

fzf-help() {
  local fzf_help_path="${HOME}/.bashrc_zen.d/fzf-help.md"
  local pager

  if command -v bat >/dev/null 2>&1; then
    pager=bat
  elif command -v less >/dev/null 2>&1; then
    pager=less
  elif command -v cat >/dev/null 2>&1; then
    pager=cat
  else
    printf >&2 'fzf-help: no usable pager found (bat/less/cat)\n'
    return 1
  fi

  if [[ ! -f "${fzf_help_path}" ]]; then
    printf >&2 'fzf-help: cannot find %s\n' "${fzf_help_path}"
    return 1
  fi

  "${pager}" "${fzf_help_path}"
}
