#!/usr/bin/env bash
# This script triggers roughly 1 in 100 times when sourced from ~/.bashrc

if ((RANDOM % 40 == 0)); then
  if command -v pipx &>/dev/null; then
    pipx upgrade-all
  fi
fi
