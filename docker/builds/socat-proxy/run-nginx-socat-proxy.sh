#!/usr/bin/env bash

set -xeuo pipefail

IMAGE=nicolaka/netshoot:latest
# NAME="${IMAGE%:*}0"
NAME0="socat-proxy99"
NAME1="nginx99"
NET0="${NAME0}-net"
NET1="${NAME1}-net"
COMMAND="socat TCP-LISTEN:80,fork,reuseaddr TCP:${NAME1}:80"

docker rm -f "${NAME0}" || true
docker rm -f "${NAME1}" || true

docker network create "${NET0}" || true
sleep 2
docker network create "${NET1}" || true
sleep 2
docker run -d --rm --hostname "${NAME1}" --network "${NET1}" --name "${NAME1}" nginx:latest
sleep 2
docker run -d --rm --hostname "${NAME0}" --name "${NAME0}" --network "${NET0}" --network "${NET1}" "${IMAGE}" ${COMMAND}
sleep 2
docker run --rm --network "${NET0}" curlimages/curl -v "${NAME0}"
