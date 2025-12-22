#!/usr/bin/env bash

set -xeuo pipefail

mkdir -p -- "$HOME/.config/nvim"
cp -r -- "$HOME/gitdir/starter/." "$HOME/.config/nvim"
