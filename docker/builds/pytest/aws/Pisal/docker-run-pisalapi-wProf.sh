#!/usr/bin/env bash

set -euo pipefail

docker run -it -p 9001:9001 \
  -e "SPRING_PROFILES_ACTIVE=test" \
  --name pisalapi \
  docker
docker pull docker-repository.healthresearch.org:8443/pisalapi:latest
