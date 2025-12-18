#!/usr/bin/env bash
# 1. run ./build-rust.sh # or bat ripgrep fd
# curl https://sh.rustup.rs -sSf | sh
# cargo install --git repo_url
# cargo install --git repo_url --branch|tag|rev branch_name|tag|commit_hash
#
#####  Installs in ~/.cargo/bin in the container mapped to ~/.cargo/bin on the host
#
# ./build-rust.sh fd
# ./build-rust.sh ripgrep
# ./build-rust.sh bin
#
# ./build-rust.sh coreutils
# ./build-rust.sh diffutils
# ./build-rust.sh findutils
# ./build-rust.sh util-linux
# ./build-rust.sh platform-info
# ./build-rust.sh procps
# ./build-rust.sh sed
# ./build-rust.sh gping
# ./build-rust.sh procs
# ./build-rust.sh bottom
# ./build-rust.sh broot
# ./build-rust.sh hexyl
# ./build-rust.sh xh
# ./build-rust.sh fd
# ./build-rust.sh rigrep
# ./build-rust.sh bat
# ./build-rust.sh eza
# ./build-rust.sh dust
# ./build-rust.sh bandwhich
# ./build-rust.sh zellij
# ./build-rust.sh zoxide
# ./build-rust.sh starship
# ./build-rust.sh cargo-update
# ./build-rust.sh ddgr
#
set -euo pipefail

# Check if arguments provided
if [ $# -eq 0 ]; then
  echo "Error: No crate name provided"
  echo "Usage: $0 <crate_name> [additional_args...]"
  echo "Example: $0 fd"
  echo "Example: $0 ripgrep"
  exit 1
fi

BUILDERNAME=rusto
DESTDIR="$HOME/temp"

echo "######################"
echo "#"
echo "#  Building ${BUILDERNAME}"
echo "#  Target: ${DESTDIR}"
echo "#"
echo "######################"

# Create cargo directory if it doesn't exist
mkdir -p "$DESTDIR"

# Build image if it doesn't exist
if ! docker images | grep -q "${BUILDERNAME}"; then
  echo "Building Rust Environment Container..."
  docker build -t "${BUILDERNAME}" -f ./Dockerfile.Rust.Builder .
  echo "Rust Environment Container build completed"
else
  echo "Rust Environment Container already exists"
fi

echo "Installing Rust crate: $1"
docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd):/workspace" \
  -v "$HOME/temp:/home/$(whoami)/.cargo" \
  -e CARGO_HOME="/home/$(whoami)/.cargo" \
  -w /workspace \
  rusto \
  cargo install --target x86_64-unknown-linux-musl "$@"

echo "Installation completed. Binary should be available in $HOME/temp/bin/"
