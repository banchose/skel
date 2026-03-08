#!/usr/bin/env bash

set -xeuo pipefail

sudo apt update
sudo apt install libclang-dev

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

~/.cargo/bin/cargo install tree-sitter-cli

which -a tree-sitter

export export PATH="$HOME/.cargo/bin:$PATH" # Cargo and in maybe in .bashrc
