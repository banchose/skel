#!/usr/bin/env bash

set -xeuo pipefail

CONTAINERNAME="trixie0"

cd ~/gitdir/skel/docker/builds/"${CONTAINERNAME}" && docker build -t "${CONTAINERNAME}" .
docker run -it --rm --name "${CONTAINERNAME}" --hostname "${CONTAINERNAME}" -v ~/temp:/home/loon/temp "${CONTAINERNAME}"
