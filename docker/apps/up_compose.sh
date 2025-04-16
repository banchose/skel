#!/usr/bin/env bash

set -euo pipefail

cd /apps

cd ./traefik
docker compose up -d
cd ..

sleep 5

for dir in ./*/; do
  echo "hitting ${dir}..."
  [[ ${dir} = *traefik* ]] && {
    echo "Skipping ${dir}"
    continue
  }
  cd "${dir}"
  docker compose up -d
  cd ..
  sleep 2
done
