#!/usr/bin/env bash

set -euo pipefail

# Copy over etc/certs/
# Copy over etc/ if needed
# Copy over .env for api keys and such
# Copy over ./librechat.yaml
# Copy over nginx-content/
#
# Apps
# Copy over ./dashy

mkdir -p -- ./config
mkdir -p -- ./dashy
mkdir -p -- ./data
mkdir -p -- ./data/watchYourLAN
mkdir -p -- ./etc/{certs,traefik}
mkdir -p -- ./homer
mkdir -p -- ./logs
mkdir -p -- ./meilisearch_data
mkdir -p -- ./mongodb_data
mkdir -p -- ./nginx-content
mkdir -p -- ./privatebin-data
mkdir -p -- ./uploads
