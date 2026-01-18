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
  apk add musl-dev
  apk add make
  apk add cmake
  apk add nmap
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
pipx install httpie --include-deps
pipx install pgcli
# pipx install mycli
pipx install pycowsay
pipx install esptool
pipx install litecli
pipx install ruff
pipx install black
pipx install feedparser --include-deps
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
pipx install llm
pipx install aider-chat
# pipx install ansible
pipx install cfn-lsp-extra
pipx install cookiecutter
pipx install csvkit
pipx install elia-chat
# pipx install openai
pipx install ptpython
pipx install s3cmd
pipx install shell-functools
pipx install speedtest-cli
pipx install twisted
pipx install visidata
pipx install psutils
pipx install uv
pipx install --force 'litellm[proxy]'
pipx install git-filter-repo

pipx inject llm llm-tools-exa --pip-args="--upgrade"
pipx inject llm llm-openrouter --pip-args="--upgrade"
pipx inject llm llm-anthropic --pip-args="--upgrade"
pipx inject llm llm-gemini --pip-args="--upgrade"
pipx inject llm llm-fragments-github --pip-args="--upgrade"
pipx inject llm llm-tools-simpleeval --pip-args="--upgrade"
pipx inject llm llm-cmd-comp --pip-args="--upgrade"
pipx inject llm llm-cmd --pip-args="--upgrade"
pipx inject llm llm-python --pip-args="--upgrade" --force
pipx inject llm llm-jq --pip-args="--upgrade" --force
pipx inject llm llm-templates-fabric --pip-args="--upgrade"
pipx inject llm howdoi --pip-args="--upgrade"
pipx inject llm httpx --pip-args="--upgrade"
pipx inject llm psutils --pip-args="--upgrade"
pipx inject llm beautifulsoup4 --pip-args="--upgrade"
pipx inject llm certifi --pip-args="--upgrade"
pipx inject llm uv --pip-args="--upgrade"
pipx inject llm 'litellm[proxy]' --pip-args="--upgrade" --force

pipx inject \
  ipython \
  boto3 \
  boltons \
  beautifulsoup4 \
  psutils \
  howdoi \
  pydantic \
  cryptography \
  black \
  pendulum \
  icecream \
  loguru \
  certifi \
  pydantic \
  httpx \
  networkx \
  pandas \
  esptool \
  numpy \
  ipython-extensions \
  llm \
  llm-tools-exa \
  llm-openrouter \
  llm-fragments-github \
  llm-anthropic \
  llm-tools-simpleeval \
  llm-python \
  llm-jq \
  httpie \
  uv \
  'litellm[proxy]' \
  --pip-args="--upgrade"

pipx ensurepath

############## Rust ##############

# command -v fd &>/dev/null || cargo install fd-find
# command -v rg &>/dev/null || cargo install ripgrep

# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

# Install bat
if ! command -v bat &>/dev/null; then
  mkdir -p ~/gitdir
  cd ~/gitdir || {
    echo "failed to cd into ~/gitdir"
    exit 1
  }
  git clone --depth=1 https://github.com/sharkdp/bat
  cd bat || {
    echo "failed to cd into ~/bat"
    exit 1
  }
  cargo install --path . --locked
fi

# neovim
build_neovim() {
  mkdir -p /BUILD
  cd /BUILD || {
    echo "failed to cd into ~/BUILD"
    return 1
  }
  git clone https://github.com/neovim/neovim.git >/dev/null
  cd neovim || {
    echo "failed to cd into neovim"
    return 1
  }
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

# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
# ~/.fzf/install

# ping -q -l 1 -c 1 www.github.com &>/dev/null && echo "build_neovim"
# ping -q -l 1 -c 1 www.github.com &>/dev/null && echo "get_lazyvim"
