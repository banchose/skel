#!/usr/bin/env bash

set -xeuo pipefail

CONTAINERNAME="py1"

cd ~/gitdir/skel/docker/builds/"${CONTAINERNAME}" &&
  docker build --build-arg USER_UID="$(id -u)" --build-arg USER_GID="$(id -g)" -t "${CONTAINERNAME}":latest . &&
  docker run -it --rm --name "${CONTAINERNAME}" --hostname "${CONTAINERNAME}" -v ~/temp:/home/loon/temp "${CONTAINERNAME}"
