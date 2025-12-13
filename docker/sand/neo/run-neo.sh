#!/usr/bin/env bash

set -xeuo pipefail

docker build -t neo:latest .
docker run --rm -it --name neo --hostname neo neo:latest
