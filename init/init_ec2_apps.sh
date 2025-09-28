#!/usr/bin/env bash

set -xuo pipefail

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
# export AUSERNAME=

sudo yum install -y wireshark-cli
sudo yum install -y tmux
sudo yum install -y mtr
sudo yum install -y jq
sudo yum install -y cowsay
sudo yum install -y git
sudo yum install -y python3
sudo yum install -y python3-pip
sudo yum install -y npm
sudo yum install -y nodejs
sudo yum install -y cargo
sudo yum install -y ninja-build
sudo yum install -y cmake
sudo yum install -y gcc
sudo yum install -y make
sudo yum install -y unzip --allowerasing
sudo yum install -y gettext
sudo yum install -y curl --allowerasing
sudo yum install -y rust
sudo yum install -y rust-doc
sudo yum install -y nmap
sudo yum install -y p7zip
sudo yum install -y p7zip-plugins
sudo yum install -y p7zip-doc
sudo yum install -y socat
sudo yum install -y ncurses
sudo yum install -y golang

echo "Installing neovim"

cd ~/gitdir
git clone https://github.com/neovim/neovim.git
cd neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo &>/dev/null
sudo make install &>/dev/null

echo "Exiting neovim install"

# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
# For eks in case links are needed
#( cd /tmp
# curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/arm64/kubectl &&
#   sudo mv ./kubectl /usr/local/bin && sudo chmod +x /usr/local/bin/kubectl
# echo "*** Movedd kubectl to /usr/local/bin"
#
# # curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/arm64/kubectl.sha256
# # curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/arm64/kubectl
# # # for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
# ARCH=arm64
# PLATFORM=$(uname -s)_$ARCH
#
# curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
#
# # (Optional) Verify checksum
# curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check
#
# tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
#
# echo "*** Moving eksctl to /usr/local/bin"
#
# sudo mv /tmp/eksctl /usr/local/bin && sudo chmod +x /usr/local/bin/eksctl
#)
#################################################################################
#
# Executed as the user $AUSERNAME
#
#################################################################################
sudo -u "$AUSERNAME" bash <<'EOF'
python3 -m pip install --user pipx || { echo "Failed to install pipx"; exit 1; }

mkdir ~/temp ~/gitdir
(
  cd ~/gitdir
  git clone https://github.com/banchose/skel
  cd skel
  ./disperse.sh
)

# Add to PATH for current session
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# Verify pipx is available
if ! command -v pipx &>/dev/null; then
    echo "pipx not found in PATH after installation"
    exit 1
fi

# Use pipx ensurepath to permanently add pipx to PATH
echo "Adding pipx to PATH permanently using ensurepath..."
pipx ensurepath

echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc

# Install packages
echo "Installing pipx packages..."

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
# pipx install posting
pipx install rust
pipx install pipenv
pipx install poetry
pipx install glances
pipx install isort
pipx install speedtest
pipx install ipython
pipx install llm
pipx install aider-chat


cargo install fd-find
cargo install ripgrep

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Install bat
mkdir ~/gitdir
cd ~/gitdir && git clone --depth=1 https://github.com/sharkdp/bat && cd bat && cargo install --path . --locked
EOF
