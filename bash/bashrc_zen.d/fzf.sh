# Minimal FZF configuration that just loads the basics
#
# Check if fzf is installed, exit if not
type fzf &>/dev/null || {
  echo "fzf not found. Skipping fzf configuration."
  return 0
}

alias prev='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
