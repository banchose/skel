#!/usr/bin/env bash
set -euo pipefail
BUILDERNAME=rusto

# Build image if it doesn't exist
if ! docker images | grep -q "${BUILDERNAME}"; then
  echo "Building Rust Environment Container..."
  docker build -t "${BUILDERNAME}" -f ./Dockerfile.Rust.Builder .
  echo "Rust Environment Container build completed"
else
  echo "Rust Environment Container already exists"
fi

docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$(pwd):/workspace" \
  -v "$HOME/.cargo:/home/$(whoami)/.cargo" \
  -e CARGO_HOME="/home/$(whoami)/.cargo" \
  -w /workspace \
  rusto \
  cargo install --target x86_64-unknown-linux-musl "$@"
