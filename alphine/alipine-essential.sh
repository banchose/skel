#!/usr/bin/env bash

set -xeuo pipefail

# For Alpine Linux
if grep 'ID=alpine' /etc/os-release; then
  apk update
  apk add python3-dev
  apk add py3-pip
  apk add pipx
  apk add rust
  apk add cargo
  apk add git
  apk add make gcc musl-dev
  apk add musl-dev
  apk add make
  apk add cmake
  apk add nmap
  apk add ninja
  apk add gcc
  apk add gettext-dev
  apk add curl
  apk add tmux
  apk add jq
  apk add gawk
  apk add sed
  apk add grep
  apk add iproute2
fi
