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
