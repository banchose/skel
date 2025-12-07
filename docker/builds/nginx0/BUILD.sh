#!/usr/bin/env bash

set -xeuo pipefail

docker build -t nginx0 .
docker run -it --rm -p 8080:9001 nginx0:latest
