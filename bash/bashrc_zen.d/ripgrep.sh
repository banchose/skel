# ripgrep
# Bail early if the command isn't available (only meaningful when sourced)
(return 0 2>/dev/null) || {
  printf >&2 '%s: must be sourced, not executed\n' "${BASH_SOURCE[0]}"
  exit 1
}
command -v rg >/dev/null 2>&1 || return 0

alias editrg='nvim ~/gitdir/skel/bash/bashrc_zen.d/ripgrep.sh'
alias rgg='rg -L --smart-case --hidden --no-ignore'
