nvim_wipe() {

  # required
  [[ -d ~/.config/nvim ]] || {
    echo "~/.config/nvim already gone"
    return 0
  }
  mv -v -- ~/.config/nvim{,.bak}

  # optional but recommended
  mv -v -- ~/.local/share/nvim{,.bak}
  mv -v -- ~/.local/state/nvim{,.bak}
  mv -v -- ~/.cache/nvim{,.bak}
}

safe_input() {
  local prompt="$1"
  local regex="$2"
  local input

  while true; do
    read -r -p "$prompt" input
    # Check against the regex if provided
    if [[ -n "$regex" && ! "$input" =~ $regex ]]; then
      echo "Invalid input. Please try again."
    else
      # Escape special characters to prevent injection
      input=$(printf '%q' "$input")
      echo "$input"
      return
    fi
  done
}

nvim-help() {
  local nvim_help_path="${HOME}/gitdir/skel/nvim/nvim-help.md"
  local pager

  if command -v bat >/dev/null 2>&1; then
    pager=bat
  elif command -v less >/dev/null 2>&1; then
    pager=less
  elif command -v cat >/dev/null 2>&1; then
    pager=cat
  else
    printf >&2 'nvim-help: no usable pager found (bat/less/cat)\n'
    return 1
  fi

  if [[ ! -f "${nvim_help_path}" ]]; then
    printf >&2 'nvim-help: cannot find %s\n' "${nvim_help_path}"
    return 1
  fi

  "${pager}" "${nvim_help_path}"
}
