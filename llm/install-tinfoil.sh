#!/usr/bin/env bash

set -xueo pipefail

(
  cd /tmp
  git clone https://github.com/tinfoilsh/tinfoil-cli.git
  cd tinfoil-cli
  go build -o tinfoil
  sudo mv tinfoil /usr/local/bin/
)
