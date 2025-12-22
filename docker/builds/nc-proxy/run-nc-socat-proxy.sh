#!/usr/bin/env bash

set -xeuo pipefail

# An example of port forwarding and docker custom networks
#
# This sets up 2 docker custom networks
# It puts an nginx server on one of them
# The other runs a proxy called socat-proxy99 or similar
# The socat-proxy99 container runs socat to proxy it's port 80 to the nginx server on the other docker custom network

IMAGE=nicolaka/netshoot:latest
# NAME="${IMAGE%:*}0"
NAME0="socat-proxy99"
NAME1="nc99"
NET0="${NAME0}-net"
NET1="${NAME1}-net"
COMMAND="socat TCP-LISTEN:80,fork,reuseaddr TCP:${NAME1}:80"

docker rm -f "${NAME0}" || true
docker rm -f "${NAME1}" || true

docker network create "${NET0}" || true
sleep 1
docker network create "${NET1}" || true
sleep 1
docker run -d --rm --hostname "${NAME1}" --network "${NET1}" --name "${NAME1}" bash:latest bash -c 'while true; do echo -e "HTTP/1.1 200 OK\n\n$(date)" | nc -l -p 1500; done'
sleep 1
docker run -d --rm -p 8080:80 --hostname "${NAME0}" --name "${NAME0}" --network "${NET0}" --network "${NET1}" "${IMAGE}" ${COMMAND}
sleep 1
# docker run --rm --network "${NET0}" curlimages/curl -v localhost:8080
curl -v localhost:8080
