#!/usr/bin/env bash

set -uo pipefail

cd /apps

cd ./traefik
docker compose pull
cd ..

sleep 1

for dir in ./*/; do
  echo "hitting ${dir}..."
  [[ ${dir} = *traefik* ]] && {
    echo "Skipping ${dir}"
    continue
  }
  cd "${dir}"
  [[ -d ./.git ]] && {
    echo "dir: ${dir}"
    git fetch --prune && git pull
  }
  docker compose pull
  cd ..
  sleep 1
done
