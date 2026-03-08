#!/usr/bin/env bash

set -xeuo pipefail

sudo apt update
sudo apt install libclang-dev
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
cargo install tree-sitter-cli
which -a tree-sitter-cli
