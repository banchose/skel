#!/usr/bin/env bash

set -euo pipefail

docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd):/workspace" \
  -v "$HOME/.cargo:/home/$(whoami)/.cargo" \
  -e CARGO_HOME="/home/$(whoami)/.cargo" \
  -w /workspace \
  rusto \
  cargo install --target x86_64-unknown-linux-musl "$@"

# chmod +x build-rust.sh
