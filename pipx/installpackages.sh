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
pipx install checkov
# pipx install ipython
pipx install csvkit
pipx install twisted
pipx install ipython --include-deps
# pipx install ansible --include deps
pipx install httpie
pipx install httpx
pipx install pgcli
pipx install mycli
pipx install pycowsay
pipx install litecli
pipx install ruff
pipx install black
pipx install flake8
pipx install pylint
pipx install cfn-lint
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
pipx install flask
pipx install django
pipx install pandas
pipx install speedtest

pipx inject ipython boto3 cryptography black pendulum icecream loguru pydantic httpx pandas numpy httpie --force
