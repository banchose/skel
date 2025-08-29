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
pipx install csvkit
pipx install twisted
pipx install ipython --include-deps
# pipx install ansible --include deps
pipx install httpie
pipx install httpx
pipx install pgcli
pipx install mycli
pipx install iredis
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
pipx install howdoi
pipx install django
pipx install pandas

pipx inject ipython boto3 boltons howdoi pydantic cryptography black pendulum psutil icecream loguru pydantic httpx pandas numpy httpie --force

# ipython --TerminalInteractiveShell.editing_mode=vi
# ~/.ipython/profile_default/ipython_config.py
# c.TerminalInteractiveShell.editing_mode = 'vi'
