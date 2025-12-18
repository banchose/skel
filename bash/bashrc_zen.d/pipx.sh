echo "BASH COMPLETIONS: Modifying bash completion pipx"
eval "$(register-python-argcomplete pipx)"

if ((RANDOM % 50 == 0)); then
  if command -v pipx &>/dev/null; then
    pipx upgrade-all
  fi
fi
