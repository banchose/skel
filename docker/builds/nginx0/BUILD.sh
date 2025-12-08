#!/usr/bin/env bash

set -xeuo pipefail

echo "###################"
docker build -t nginx0 .
echo "###################"
docker run -it --rm -p 8080:9001 nginx0:latest
