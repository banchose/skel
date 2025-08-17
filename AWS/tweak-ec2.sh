#!/usr/bin/env bash

set -euo pipefail

sudo yum -y install python3 tmux nodejs python3-pip ninja-build cmake gcc make unzip gettext jq curl git --allowerasing

[[ -d ~/temp ]] || mkdir ~/temp
[[ -d ~/gitdir ]] || mkdir ~/gitdir

cd ~/gitdir
git clone https://github.com/neovim/neovim.git
cd ~/gitdir/neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install

sudo yum install python3
sudo yum install nodejs -y
sudo yum install npm -y
sudo yum install python3-pip

python3 -m pip install --user pipx

set +e
pipx install httpie
pipx install pgcli
pipx install mycli
pipx install pycowsay
pipx install litecli
pipx install ruff
pipx install black
pipx install flake8
pipx install pylint
pipx install cfn-lint
pipx install pipenv
pipx install poetry
pipx install glances
pipx install isort
pipx install speedtest
pipx install ipython
