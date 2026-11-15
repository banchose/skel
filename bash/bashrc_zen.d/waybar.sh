# Bail early if the command isn't available (only meaningful when sourced)
(return 0 2>/dev/null) || {
  printf >&2 '%s: must be sourced, not executed\n' "${BASH_SOURCE[0]}"
  exit 1
}
command -v waybar >/dev/null 2>&1 || return 0

rebar() {
  pkill waybar && waybar &>/dev/null &
}
