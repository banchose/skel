#!/usr/bin/env bash
set -euo pipefail

# pip install --user pipx
# pipx ensurepath
# PyPi
# pipx completions
pipx install checkov --include-deps
# pipx install ipython --include-deps
pipx install csvkit --include-deps
pipx install twisted --include-deps
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
