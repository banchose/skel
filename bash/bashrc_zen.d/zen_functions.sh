GitZenDir="${HOME}/gitdir/skel/bash/bashrc_zen.d"
LocalZenDir="${HOME}/.bashrc_zen.d"

command -v fzf &>/dev/null || {
  echo "NO fzf. Skipping..."
  return 0
}

zen() {
  local pick
  pick=$(find "$GitZenDir" -maxdepth 1 -type f -name '*.sh' -printf '%f\n' 2>/dev/null |
    sort |
    fzf --prompt='zen.d> ' --height=40% --reverse \
      --preview="cat '$GitZenDir'/{}" --preview-window=right:60%) || return
  [[ -n $pick ]] && nvim "$GitZenDir/$pick"
}
