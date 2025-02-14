#!/usr/bin/bash

set -xeuo pipefail

[[ -e ~/.local/bin/aider ]] && {
  echo "aider found in ~/.local/bin"
  echo "NOT installing"
  return 1
}

[[ -e ~/.aider.conf.yml ]] && {
  echo "Found ~/.aider.conf.yml - too scared"
  echo "NOT installing"
  return 1
}

if command -v python &>/dev/null; then
  python -m pip install --user pipx && eval "$(register-python-argcomplete pipx)"
else
  echo "I could not find python"
fi
