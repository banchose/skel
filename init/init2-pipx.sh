#!/usr/bin/env bash

# docker run -it -v ~/temp:/root/temp:ro -v ~/.bashrc:/root/.bashrc:ro -v ~/.inputrc:/root/.inputrc:ro  -v ~/gitdir/skel:/root/skel:ro bash bash
# mkdir gitdir;cd gitdir;git clone https://github.com/banchose/skel;cd ./skel;./disperse.sh

set -xuo pipefail

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# For Alpine Linux
if grep -q 'ID=alpine' /etc/os-release; then
  apk update
  apk add \
    python3-dev py3-pip pipx \
    rust cargo \
    git make gcc musl-dev cmake ninja \
    nmap gettext-dev curl tmux jq gawk sed grep iproute2
fi

# Amazon AWS
if grep -q 'ID="amzn"' /etc/os-release; then
  sudo yum update
  sudo yum -y install \
    git tmux jq bash-completion zip unzip \
    ninja-build gcc cmake make gettext \
    python3.13 python3.13-pip
fi

if [[ -n ${INST_RUST:-} ]]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env"
  cargo install cargo-update fd-find ripgrep
fi

# Simple tool installs
uv tool install httpie
uv tool install pgcli
uv tool install ftfy
uv tool install mycli
uv tool install pycowsay
uv tool install html2text
uv tool install ruff
uv tool install black
uv tool install isort
uv tool install s3cmd
uv tool install speedtest-cli
uv tool install shell-functools
uv tool install posting
uv tool install litecli
uv tool install git-filter-repo
uv tool install cookiecutter
uv tool install pylint
uv tool install sqlite-utils
uv tool install flake8
uv tool install twisted
uv tool install flask
uv tool install django
uv tool install jupyter
uv tool install checkov
uv tool install cfn-lint
uv tool install openai
uv tool install open-terminal
uv tool install csvkit
uv tool install visidata
uv tool install esptool
uv tool install ansible
uv tool install glances
uv tool install aider-chat --python 3.11

uv tool install ptpython \
  --with requests --with icecream --with pendulum --with httpx --with uv

# llm with full plugin/dependency set
uv tool install --upgrade --python 3.13 llm \
  --with llm-tools-simpleeval \
  --with llm-tools-exa \
  --with llm-tools-sqlite \
  --with llm-tools-quickjs \
  --with llm-tools-datasette \
  --with llm-openrouter \
  --with llm-anthropic \
  --with llm-gemini \
  --with pymupdf-layout \
  --with llm-templates-github \
  --with llm-templates-fabric \
  --with llm-fragments-github \
  --with llm-fragments-pdf \
  --with llm-fragments-site-text \
  --with llm-cmd-comp \
  --with kubernetes \
  --with python-dateutil \
  --with llm-cmd \
  --with llm-python \
  --with llm-jq \
  --with howdoi \
  --with httpx \
  --with open-terminal \
  --with psutils \
  --with beautifulsoup4 \
  --with certifi \
  --with ftfy \
  --with uv \
  --with 'litellm[proxy]' \
  --with tinfoil

llm install llm-docs
llm install llm-sentence-transformers
llm sentence-transformers register all-MiniLM-L12-v2 --alias mini-l12
llm sentence-transformers register all-mpnet-base-v2 --alias mpnet

uv tool install --upgrade --python 3.13 ipython \
  --with boto3 \
  --with sqlite-utils \
  --with boltons \
  --with beautifulsoup4 \
  --with psutils \
  --with howdoi \
  --with pydantic \
  --with kubernetes \
  --with python-dateutil \
  --with cryptography \
  --with black \
  --with pendulum \
  --with ftfy \
  --with icecream \
  --with loguru \
  --with certifi \
  --with httpx \
  --with networkx \
  --with pandas \
  --with anthropic \
  --with esptool \
  --with numpy \
  --with ipython-extensions \
  --with llm \
  --with 'litellm[proxy]' \
  --with llm-tools-exa \
  --with llm-openrouter \
  --with llm-fragments-github \
  --with llm-anthropic \
  --with llm-tools-simpleeval \
  --with llm-python \
  --with llm-jq \
  --with httpie \
  --with uv \
  --with open-terminal

# cargo installs
# cargo install atac --locked # web tui
# cargo install slumber --locked # web tui
# cargo install trippy --locked
# cargo install --git https://github.com/kamiyaa/joshuto.git --force
