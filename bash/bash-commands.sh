#!/usr/bin/env bash

set -xeuo pipefail
exit 1
(
  cd ~/y/youtube-down/
  for i in ./*; do printf '%s\n' "$i"; done | tr '[:blank:]' '_' | tr -dc '[:alnum:][:cntrl:]_./' | while IFS= read -r line; do echo "${line,,}"; done
)
