#!/usr/bin/env bash
set -xeuo pipefail

#####
#
#
# docker run -it --network test-network bash
# [on test-network] ping nginx-server-1 # Works!
# [on test-network] ping nginx-server-2 # Works!
#

# Create networks if they don't exist
docker network ls | grep -q test-network || docker network create test-network
docker network ls | grep -q test-network2 || docker network create test-network2

# Remove existing containers if they exist
docker rm -f nginx-server-1 2>/dev/null || true
docker rm -f nginx-server-2 2>/dev/null || true

# Create nginx containers on different networks
docker run -d --name nginx-server-1 --network test-network nginx:latest
docker run -d --name nginx-server-2 --network test-network2 nginx:latest

# Connect each container to the opposite network (for cross-network communication)
# You connect networks to containers
# So the container must be connected to at least one in common
docker network connect test-network nginx-server-2
docker network connect test-network2 nginx-server-1

# Now cross-network tests will work
echo "Testing nginx-server-1 from test-network2:"
docker run --rm --network test-network2 curlimages/curl http://nginx-server-1

echo "Testing nginx-server-2 from test-network:"
docker run --rm --network test-network curlimages/curl http://nginx-server-2
