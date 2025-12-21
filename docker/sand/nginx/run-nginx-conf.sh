#!/usr/bin/env bash

set -xeuo pipefail

docker run -it -v ./nginx.conf:/etc/nginx/nginx.conf --rm nginx:latest nginx -T
