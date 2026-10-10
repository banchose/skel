#!/usr/bin/env bash
set -euo pipefail

PI_VERSION="${PI_VERSION:-$(curl -fsSL https://registry.npmjs.org/@earendil-works/pi-coding-agent/latest | jq -r .version)}"
[[ -n "$PI_VERSION" && "$PI_VERSION" != null ]] || {
  echo "Could not resolve PI_VERSION" >&2
  exit 1
}

args=(
  --build-arg UID="$(id -u)"
  --build-arg GID="$(id -g)"
  --build-arg PI_VERSION="$PI_VERSION"
)
# FULL=1 ./build-pi.sh  -> refresh base image + apt layers
[[ "${FULL:-0}" == 1 ]] && args+=(--no-cache --pull)

docker build "${args[@]}" -t pi-sandbox-w .
./COPY-MCP-TO-PI-IMAGE-w.sh
