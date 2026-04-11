#!/usr/bin/env bash

# docker run -it -v ~/temp:/root/temp:ro -v ~/.bashrc:/root/.bashrc:ro -v ~/.inputrc:/root/.inputrc:ro  -v ~/gitdir/skel:/root/skel:ro bash bash
# pipx upgrade-all --include-injected

# mkdir gitdir;cd gitdir;git clone https://github.com/banchose/skel;cd ./skel;./disperse.sh

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

##
# Amazon AWS
##
if grep 'ID="amzn"' /etc/os-release; then
  sudo yum update
  sudo yum -y install git
  sudo yum -y install tmux
  sudo yum -y install jq
  sudo yum -y install bash-completion
  sudo yum -y install zip
  sudo yum -y install unzip
  sudo yum -y install ninja-build
  sudo yum -y install gcc
  sudo yum -y install cmake
  sudo yum -y install make
  sudo yum -y install gettext
  sudo yum -y install python3.13
  sudo yum -y install python3.13-pip
fi

##
# pipx applications
##
command -v pipx &>/dev/null || python3.13 -m pip install --user pipx
pipx ensurepath

pipx install httpie --include-deps
pipx install pgcli
pipx install ftfy
pipx install mycli
pipx install pycowsay
pipx install html2text
pipx install ruff
pipx install black
pipx install isort
pipx install s3cmd
pipx install speedtest-cli
pipx install psutils
pipx install uv

if [[ -n ${INST_RUST:-} ]]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source "$HOME/.cargo/env"
  cargo install cargo-update fd-find ripgrep
fi

## cargo

# if command -v rustc &>/dev/null; then
#     echo "Rust is already installed: $(rustc --version). Skipping."
#     exit 0
# fi
#
# # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# source "$HOME/.cargo/env"
#
# cargo install cargo-update fd-find ripgrep
#
# cargo install cargo-update fd-find ripgrep
# cargo install cargo-update
# cargo install fd-find
# cargo install ripgrep

if [[ -n ${INST_EXTRA:-} ]]; then
  pipx install speedtest --include-deps
  pipx install shell-functools
  pipx install posting
  pipx install litecli
  pipx install git-filter-repo
  pipx install cookiecutter
  # if [[ -n ${INST_PYTHON_EXTRA:-} ]]; then
  pipx install pylint
  pipx install sqlite-utils
  pipx install flake8
  pipx install ipython --include-deps
  pipx install ptpython
  pipx inject ptpython requests icecream pendulum httpx uv --pip-args="--upgrade"
  pipx install networkx
  pipx install httpx
  pipx install twisted
  pipx install copyparty
  pipx install icecream
  pipx install flask --include-deps
  pipx install django --include-deps
  pipx install jupyter
  # pipx install pandas --include-deps
  ##### aws
  # pipx install cfn-lsp-extra
  pipx install checkov
  pipx install cfn-lint
  ##### llm
  pipx install llm && command llm install llm-docs
  pipx install aider-chat --include-deps
  pipx install 'litellm[proxy]'
  #  pipx install litellm
  pipx install openai
  pipx install anthropic --include-deps
  pipx install open-terminal
  ####    pipx install openai-whisper # HUGE
  # pipx install tinfoil --include-deps
  # pipx install elia-chat
  ##### Exta
  pipx install feedparser --include-deps
  pipx install csvkit
  pipx install visidata
  pipx install esptool
  pipx install ansible
  pipx install glances
fi

# pipx inject llm xxxxx --pip-args="--upgrade"

if command -v llm &>/dev/null; then
  pipx inject llm llm-tools-simpleeval --pip-args="--upgrade"
  pipx inject llm llm-tools-exa --pip-args="--upgrade"
  pipx inject llm llm-tools-sqlite --include-deps --pip-args="--upgrade"
  pipx inject llm llm-tools-quickjs --include-deps --pip-args="--upgrade"
  pipx inject llm llm-tools-datasette --include-deps --pip-args="--upgrade"
  pipx inject llm llm-openrouter --pip-args="--upgrade"
  pipx inject llm llm-anthropic --pip-args="--upgrade"
  pipx inject llm llm-gemini --pip-args="--upgrade"
  pipx inject llm pymupdf-layout --pip-args="--upgrade"
  pipx inject llm llm-templates-github --pip-args="--upgrade"
  pipx inject llm llm-templates-fabric --pip-args="--upgrade"
  pipx inject llm llm-fragments-github --pip-args="--upgrade"
  pipx inject llm llm-fragments-pdf --pip-args="--upgrade"
  pipx inject llm llm-fragments-site-text --pip-args="--upgrade"
  pipx inject llm llm-sentence-transformers --pip-args="--upgrade"
  pipx inject llm llm-cmd-comp --pip-args="--upgrade"
  pipx inject llm kubernetes --pip-args="--upgrade"
  pipx inject llm python-dateutil --pip-args="--upgrade"
  pipx inject llm llm-cmd --pip-args="--upgrade"
  pipx inject llm llm-python --pip-args="--upgrade" --force
  pipx inject llm llm-jq --pip-args="--upgrade" --force
  pipx inject llm howdoi --pip-args="--upgrade"
  pipx inject llm httpx --pip-args="--upgrade"
  pipx inject llm open-terminal --pip-args="--upgrade"
  pipx inject llm psutils --pip-args="--upgrade"
  pipx inject llm beautifulsoup4 --pip-args="--upgrade"
  pipx inject llm certifi --pip-args="--upgrade"
  pipx inject llm ftfy --pip-args="--upgrade"
  pipx inject llm uv --pip-args="--upgrade"
  # pipx inject llm 'litellm[proxy]' --pip-args="--upgrade"
  pipx inject llm litellm --pip-args="--upgrade"
  pipx inject llm tinfoil --include-deps --pip-args="--upgrade"
  llm sentence-transformers register all-MiniLM-L12-v2 --alias mini-l12
  llm sentence-transformers register all-mpnet-base-v2 --alias mpnet
  # llm install llm-sentence-transformers
  uv tool install strip-tags
fi

if command -v ipython &>/dev/null; then
  pipx inject \
    ipython \
    boto3 \
    sqlite-utils \
    copyparty \
    boltons \
    beautifulsoup4 \
    psutils \
    howdoi \
    pydantic \
    kubernetes \
    python-dateutil \
    cryptography \
    black \
    pendulum \
    ftfy \
    icecream \
    loguru \
    certifi \
    pydantic \
    httpx \
    networkx \
    pandas \
    anthropic \
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
    litellm \
    open-terminal \
    --pip-args="--upgrade"
#   --include-deps
fi

## cargo

# if command -v rustc &>/dev/null; then
#     echo "Rust is already installed: $(rustc --version). Skipping."
#     exit 0
# fi
#
# # curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# source "$HOME/.cargo/env"
#
# cargo install cargo-update fd-find ripgrep
#
# cargo install cargo-update fd-find ripgrep
# cargo install cargo-update
# cargo install fd-find
# cargo install ripgrep

############## Rust ##############

# command -v fd &>/dev/null || cargo install fd-find
# command -v rg &>/dev/null || cargo install ripgrep

# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install

# # Install bat
# if ! command -v bat &>/dev/null; then
#   mkdir -p ~/gitdir
#   cd ~/gitdir || {
#     echo "failed to cd into ~/gitdir"
#     exit 1
#   }
#   git clone --depth=1 https://github.com/sharkdp/bat
#   cd bat || {
#     echo "failed to cd into ~/bat"
#     exit 1
#   }
#   cargo install --path . --locked
# fi

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
