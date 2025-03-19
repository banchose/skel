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
# pipx install ipython --include-deps
pipx install csvkit --include-deps
pipx install twisted --include-deps
pipx install ipython --include-deps
# pipx install ansible --include deps
pipx install httpie --include-deps
pipx install pgcli --include-deps
pipx install mycli --include-deps
pipx install pycowsay --include-deps
pipx install litecli --include-deps
pipx install ruff --include-deps
pipx install black --include-deps
pipx install flake8 --include-deps
pipx install pylint --include-deps
pipx install cfn-lint --include-deps
pipx install posting --include-deps
pipx install pipenv --include-deps
pipx install poetry --include-deps
pipx install glances --include-deps
pipx install jupyter --include-deps
pipx install cookiecutter --include-deps
pipx install visidata --include-deps
pipx install esptool --include-deps
pipx install shell-functools --include-deps
pipx install isort --include-deps
pipx install flask --include-deps
pipx install django --include-deps
pipx install pandas --include-deps
pipx install speedtest --include-deps
