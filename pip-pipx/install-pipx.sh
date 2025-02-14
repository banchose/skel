#!/usr/bin/bash

set -xeuo pipefail

python -m pip install --user pipx
eval "$(register-python-argcomplete pipx)"
