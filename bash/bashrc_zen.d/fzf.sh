# FZF configuration and key bindings
# Check if fzf is installed
type fzf &>/dev/null || return 0

if type fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --hidden --exclude ".git" --exclude "gitdir"'
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
elif type rg &>/dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git" --glob "!gitdir"'
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
elif type find &>/dev/null; then
  export FZF_DEFAULT_COMMAND='find . -type f ! -path "*git*"'
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
fi

# Remove the preview options that cause the "unknown option: {}" error
export FZF_CTRL_T_OPTS=""

# Default options
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

alias fzfmod='find . -type f -printf "%T@ %p\n" | sort -nr | cut -d" " -f2- | fzf'

# Source fzf completion and key-bindings
[[ -r /usr/share/fzf/completion.bash ]] && source /usr/share/fzf/completion.bash
[[ -r /usr/share/fzf/key-bindings.bash ]] && source /usr/share/fzf/key-bindings.bash

# Create a custom alternative to CTRL-T (using CTRL-F instead)
# This avoids conflicts with Windows Terminal's CTRL-T binding
fzf-file-widget-custom() {
  local cmd="$FZF_CTRL_T_COMMAND"
  local out selected
  out=$(eval "$cmd" | fzf)
  if [ -n "$out" ]; then
    selected=$(printf '%q ' "$out")
    READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
    READLINE_POINT=$((READLINE_POINT + ${#selected}))
  fi
}

# Bind CTRL-F instead of CTRL-T
bind -x '"\C-f": fzf-file-widget-custom'

vf() {
  local file
  command -v fzf &>/dev/null && file="$(fzf)"
  [[ -f "$file" ]] && nvim "${file}"
}

vz() {
  (
    [[ -d ~/gitdir/skel/bash/bashrc_zen.d ]] || {
      echo "Missing ~/gitdir/skel/bash/bashrc_zen.d/"
      return 1
    }
    command -v fzf &>/dev/null && file="$(fzf)"
    [[ -f "$file" ]] && nvim "${file}"
  )
}
