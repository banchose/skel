#!/usr/bin/env bash

set -xeuo pipefail

docker build --build-arg UID="$(id -u)" --build-arg GID="$(id -g)" -t pi-sandbox .
./COPY-MCP-TO-PI-IMAGE.sh
