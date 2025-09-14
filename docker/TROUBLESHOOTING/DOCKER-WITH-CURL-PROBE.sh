#!/usr/bin/env bash

set -xeuo pipefail

docker network ls | grep -s test-network || docker network create test-network

# First nginx container
docker ps | grep -s nginx-server-1 || docker run -d --name nginx-server-1 --network test-network nginx:latest
docker ps | grep -s nginx-server-2 || docker run -d --name nginx-server-2 --network test-network nginx:latest

# Test first nginx container (port 80 internally)
docker run --rm --network test-network curlimages/curl http://nginx-server-1

# Test second nginx container (port 80 internally)
docker run --rm --network test-network curlimages/curl http://nginx-server-2

# Test with headers
docker run --rm --network test-network curlimages/curl -I http://nginx-server-1
docker run --rm --network test-network curlimages/curl -I http://nginx-server-2

# Test with verbose output
docker run --rm --network test-network curlimages/curl -v http://nginx-server-1
docker run --rm --network test-network curlimages/curl -v http://nginx-server-2
