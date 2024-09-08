#!/usr/bin/env bash

set -euo pipefail

ArchCacheDir=/var/cache/nginx/archmirror
ArchNginxWebDir=/srv/http/pacman-cache

sudo pacman -S nginx --needed

sudo mkdir -p "${ArchCacheDir}"
sudo chown -R www-data:www-data "${ArchCacheDir}"
sudo chmod -R 755 "${ArchCacheDir}"

sudo mkdir -p "${ArchNginxWebDir}"
sudo chown -R www-data:www-data "${ArchNginxWebDir}"
sudo chmod -R 755 "${ArchNginxWebDir}"

[[ -e ./nginx.conf ]] && sudo cp /etc/nginx/nginx.conf{,.scriptcreatedbackup} &&
  sudo cp ./nginx.conf /etc/nginx
