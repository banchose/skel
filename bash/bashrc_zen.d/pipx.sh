echo "BASH COMPLETIONS: Modifying bash completion pipx"
eval "$(register-python-argcomplete pipx)"

if ((RANDOM % 100 == 0)); then
  if command -v pipx &>/dev/null; then
    pipx upgrade-all --include-injected
  fi
fi
