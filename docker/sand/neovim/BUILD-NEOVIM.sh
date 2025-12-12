#!/usr/bin/env bash

set -xeuo pipefail

docker run -it --rm --name neobuild --hostname neobuild neobuild:latest
