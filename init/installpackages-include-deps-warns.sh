#!/usr/bin/env bash
set -euo pipefail

# sudo apt update && sudo apt install python3-venv python3-pip

# pip install --user pipx
# command -v pipx >/dev/null &>/dev/null || pip install --user pipx
# pipx ensurepath
# pipx completions
# echo 'eval "$(register-python-argcomplete pipx)"' >> ~/.bashrc
# source ~/.bashrc
# pipx environment
# PyPi
# pipx completions
pipx install checkov --include-deps
pipx install ipython --include-deps
pipx install csvkit
pipx install twisted
pipx install ipython
# pipx install ansible --include deps
pipx install httpie
pipx install pgcli
pipx install mycli
pipx install pycowsay
pipx install litecli
pipx install ruff
pipx install black
pipx install flake8 --include-deps
pipx install pylint
pipx install cfn-lint --include-deps
pipx install posting
pipx install pipenv
pipx install poetry
pipx install glances
pipx install jupyter
pipx install cookiecutter
pipx install visidata
pipx install esptool
pipx install shell-functools
pipx install isort
pipx install flask --include-deps
pipx install django --include-deps
pipx install pandas --include-deps
pipx install speedtest --include-deps
