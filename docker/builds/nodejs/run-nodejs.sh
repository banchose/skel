#!/usr/bin/env bash

set -euo pipefail

docker build -t mynode:latest . &&
  docker run --rm -it --name "mynode" --hostname "mynode" mynode:latest
