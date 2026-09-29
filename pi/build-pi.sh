#!/usr/bin/env bash
set -euo pipefail

# Resolve the real version so the cache key changes only when upstream does.
PI_VERSION="${PI_VERSION:-$(npm view @earendil-works/pi-coding-agent version)}"

args=(
  --build-arg UID="$(id -u)"
  --build-arg GID="$(id -g)"
  --build-arg PI_VERSION="$PI_VERSION"
)
# FULL=1 ./build-pi.sh  -> refresh base image + apt layers
[[ "${FULL:-0}" == 1 ]] && args+=(--no-cache --pull)

docker build "${args[@]}" -t pi-sandbox .
./COPY-MCP-TO-PI-IMAGE.sh
