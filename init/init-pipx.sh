#!/usr/bin/env bash

# docker run -it -v ~/temp:/root/temp:ro -v ~/.bashrc:/root/.bashrc:ro -v ~/.inputrc:/root/.inputrc:ro  -v ~/gitdir/skel:/root/skel:ro bash bash
# pipx upgrade-all --include-injected

set -xuo pipefail

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# For Alpine Linux
if grep 'ID=alpine' /etc/os-release; then
  apk update
  apk add python3-dev
  apk add py3-pip
  apk add pipx
  apk add rust
  apk add cargo
  apk add git
  apk add make gcc musl-dev
  apt add build-essential
  apk add musl-dev
  apk add make
  apk add cmake
  apk add nmap
  apk add esptool
  apk add ninja
  apk add gcc
  apk add gettext-dev
  apk add curl
  apk add tmux
  apk add jq
  apk add gawk
  apk add sed
  apk add grep
  apk add iproute2
fi

command -v pipx || {
  echo "no pipx"
  exit 1
}
pipx install checkov --include-deps
pipx install ipython --include-deps
pipx install flask --include-deps
pipx install django --include-deps
pipx install pandas --include-deps
pipx install speedtest --include-deps
pipx install httpie
pipx install pgcli
# pipx install mycli
pipx install pycowsay
pipx install litecli
pipx install ruff
pipx install black
pipx install flake8
pipx install pylint
pipx install cfn-lint
# pipx install posting
pipx install rust
pipx install pipenv
pipx install poetry
pipx install glances
pipx install isort
# pipx install jupyter
pipx install ipython
pipx install llm
pipx install aider-chat
pipx install ansible
pipx install cfn-lint
pipx install cfn-lsp-extra
pipx install cookiecutter
pipx install csvkit
pipx install elia-chat
pipx install llm
pipx install openai
pipx install ptpython
pipx install pycowsay
pipx install s3cmd
pipx install shell-functools
pipx install speedtest-cli
pipx install twisted
pipx install visidata
pipx install psutils

pipx inject llm llm-tools-exa --pip-args="--upgrade" --force
pipx inject llm llm-openrouter --pip-args="--upgrade"
pipx inject llm llm-anthropic --pip-args="--upgrade" --force
pipx inject llm llm-fragments-github --pip-args="--upgrade" --force
pipx inject llm llm-tools-simpleeval --pip-args="--upgrade" --force
pipx inject llm llm-cmd-comp --pip-args="--upgrade" --force
pipx inject llm llm-cmd --pip-args="--upgrade" --force
pipx inject llm llm-templates-fabric --pip-args="--upgrade" --force
pipx inject llm howdoi --pip-args="--upgrade" --force
pipx inject llm httpx --pip-args="--upgrade" --force
pipx inject llm psutils --pip-args="--upgrade" --force

pipx inject \
  ipython \
  boto3 \
  boltons \
  psutils \
  howdoi \
  pydantic \
  cryptography \
  black \
  pendulum \
  icecream \
  loguru \
  pydantic \
  httpx \
  pandas \
  numpy \
  ipython-extensions \
  httpie \
  --pip-args="--upgrade" \
  --force

pipx ensurepath

############## Rust ##############

cargo install fd-find
cargo install ripgrep

# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

# Install bat
mkdir ~/gitdir
cd ~/gitdir && git clone --depth=1 https://github.com/sharkdp/bat && cd bat && cargo install --path . --locked

# neovim
build_neovim() {
  mkdir /BUILD
  cd /BUILD
  git clone https://github.com/neovim/neovim.git >/dev/null
  cd neovim
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  if [[ $UID == 0 ]]; then
    make install
  else
    sudo make install
  fi
}

get_lazyvim() {

  dir=/root/.config/nvim
  mkdir -p "${dir}"
  git clone https://github.com/LazyVim/starter "${dir}"

}

# ping -q -l 1 -c 1 www.github.com &>/dev/null && echo "build_neovim"
# ping -q -l 1 -c 1 www.github.com &>/dev/null && echo "get_lazyvim"
