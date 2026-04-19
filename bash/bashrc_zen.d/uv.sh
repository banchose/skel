# Bail early if the command isn't available (only meaningful when sourced)
(return 0 2>/dev/null) || {
  printf >&2 '%s: must be sourced, not executed\n' "${BASH_SOURCE[0]}"
  exit 1
}
command -v uv >/dev/null 2>&1 || return 0

if ((RANDOM % 50 == 0)); then
  if command -v uv &>/dev/null; then
    uv tool upgrade --all
  fi
fi

uvup() {
  uv tool upgrade --all
}

edituv() {
  nvim ~/gitdir/skel/bash/bashrc_zen.d/uv.sh
}

uv_help() {
  cat <<'EOF'
uv tool upgrade --all
EOF
}
