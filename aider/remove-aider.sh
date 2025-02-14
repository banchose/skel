#!/usr/bin/env bash
set -xeuo pipefail

if command -v yay &>/dev/null; then
  yay -Rns aider
elif command -v pacman &>/dev/null; then
  pacman -Rns aider
fi
pipx uninstall aider

rm -fr -- ~/.local/bin/aider
rm -fr -- ~/.local/bin/aider-chat
rm -fr -- ~/.local/bin/aider-*
rm -rf -- ~/.config/aider
rm -rf -- ~/.cache/aider
rm -rf -- ~/.local/share/aider
rm -rf -- ~/.local/lib/aider
rm -rf -- ~/.aider*
