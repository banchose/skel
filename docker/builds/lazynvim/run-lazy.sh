#!/usr/bin/env bash

set -xeuo pipefail

docker run -it --rm -v "$HOME"/temp:/temp --hostname lazy --name lazy lazy:latest
