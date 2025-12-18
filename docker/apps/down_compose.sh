#!/usr/bin/env bash

set -uo pipefail

cd /apps

for dir in ./*/; do
  cd "${dir}"
  docker compose down
  cd ..
done
