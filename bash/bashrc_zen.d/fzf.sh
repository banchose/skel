# Minimal FZF configuration that just loads the basics
#

alias prev='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'

# Check if fzf is installed, exit if not
type fzf &>/dev/null || {
  echo "fzf not found. Skipping fzf configuration."
  return 0
}

# Define paths to required scripts
FZF_COMPLETION_SCRIPT="$HOME/.fzf/shell/completion.bash"
FZF_KEYBINDINGS_SCRIPT="$HOME/.fzf/shell/key-bindings.bash"

# Set FZF_TMUX_HEIGHT to avoid the "not a valid integer: 20+" error
export FZF_TMUX_HEIGHT="40%"

# Source the completion script if it exists
if [[ -r "$FZF_COMPLETION_SCRIPT" ]]; then
  echo "BASH COMPLETIONS: Modifying bash completion pipx"
  echo "Sourcing fzf completion from: $FZF_COMPLETION_SCRIPT"
  source "$FZF_COMPLETION_SCRIPT"
else
  echo "Warning: fzf completion script not found at $FZF_COMPLETION_SCRIPT"
fi

# Source the key bindings script if it exists
if [[ -r "$FZF_KEYBINDINGS_SCRIPT" ]]; then
  echo "KEYBINDINGS: Sourcing fzf key bindings from: $FZF_KEYBINDINGS_SCRIPT"
  source "$FZF_KEYBINDINGS_SCRIPT"
else
  echo "Warning: fzf key bindings script not found at $FZF_KEYBINDINGS_SCRIPT"
fi

# Set basic options
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_COMPLETION_TRIGGER='**'

# Enable bash globstar for ** pattern matching
shopt -s globstar 2>/dev/null

# Restore CTRL-F binding for file selection
fzf-file-widget-custom() {
  local cmd="${FZF_CTRL_T_COMMAND:-${FZF_DEFAULT_COMMAND:-find . -type f}}"
  local out selected
  out=$(eval "$cmd" | fzf)
  if [ -n "$out" ]; then
    selected=$(printf '%q ' "$out")
    READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}$selected${READLINE_LINE:$READLINE_POINT}"
    READLINE_POINT=$((READLINE_POINT + ${#selected}))
  fi
}

# Bind CTRL-F for file selection
bind -x '"\C-f": fzf-file-widget-custom'

echo "FZF configuration completed"
