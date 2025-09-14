#!/usr/bin/env bash

set -uo pipefail

for i in ripgrep bat coreutils diffutils aichat findutils util-linux platform-info procps sed gping procs bottom broot hexyl xh fd rigrep bat eza dust zoxide zellij cargo-update; do
  echo "Attempting to install: ${i}"
  ./build-rust.sh "${i}"
done
