#!/usr/bin/env bash

set -xeuo pipefail

# 1. download Let's Encrypt $BUNDLEZIP into downloads from porkbun dns side
# 2. Run this

# get package from porkbun shield little icon
#
# xaax.dev-ssl-bundle.zip

BUNDLEZIP=xaax.dev-ssl-bundle.zip
DOMCERT=domain.cert.pem
KEY=private.key.pem
PUBLICKEY=public.key.pem
# CERTDEST=/apps/traefik/etc/certs
CERTDEST=/tmp

cd ~/Downloads
[[ -r ./${BUNDLEZIP} ]] || {
  echo "missing ${BUNDLEZIP}"
  exit 1
}
unzip -- ./"${BUNDLEZIP}" || {
  echo "Error unzipping ${BUNDLEZIP}"
  exit 1
}
cd "${BUNDLEZIP%.*}"

scp -- *.pem star:"${CERTDEST}" &&
  ssh star chmod 666 "${CERTDEST}"/*.pem &&
  ssh star "cp ${CERTDEST}/domain.cert.pem ${CERTDEST}/cert.pem" &&
  ssh star "cp ${CERTDEST}/private.key.pem ${CERTDEST}/key.pem" &&
  ssh star chmod 400 "${CERTDEST}"/*.pem
