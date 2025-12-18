#!/usr/bin/env bash

set -euo pipefail

app="${1}"

gitappsdir=~/gitdir/skel/docker/apps
appsdir=/apps

mkdir "${gitappsdir}"/"${app}"
touch "${gitappsdir}"/"${app}"/docker-compose.yaml
touch "${gitappsdir}"/"${app}"/docker-compose.override.yaml

mkdir "${appsdir}"/"${app}"
cd "${appsdir}"/"${app}"
ln -s "${gitappsdir}"/"${app}"/docker-compose.yaml ./
ln -s "${gitappsdir}"/"${app}"/docker-compose.override.yaml ./
