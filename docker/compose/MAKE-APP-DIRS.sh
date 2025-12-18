#!/usr/bin/env bash

set -euo pipefail

# Copy over etc/certs/
# Copy over etc/ if needed
# Copy over .env for api keys and such
# Copy over ./librechat.yaml
# Copy over nginx-content/
#

mkdir -p -- ./config
mkdir -p -- ./data
mkdir -p -- ./data/watchYourLAN
mkdir -p -- ./etc/{certs,traefik}
mkdir -p -- ./logs
mkdir -p -- ./meilisearch_data
mkdir -p -- ./mongodb_data
mkdir -p -- ./nginx-content
mkdir -p -- ./privatebin-data
mkdir -p -- ./uploads
cp -v -- ~/gitdir/skel/docker/compose/etc/traefik/tls.yaml ./etc/traefik
cp -v -- ~/gitdir/skel/docker/compose/etc/certs/*.pem ./etc/certs
cp -v -- ~/gitdir/skel/docker/compose/nginx-content/index.html ./etc/nginx-content
cp -v -- ~/gitdir/skel/docker/compose/librechat.yaml ./
cp -v -- ~/gitdir/skel/docker/compose/.env ./
