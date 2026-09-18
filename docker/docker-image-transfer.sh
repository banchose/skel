#!/usr/bin/env bash
set -xeuo pipefail

# docker save py0:latest | zstd -T0 | ssh base0 'zstd -d | docker load'
