#!/usr/bin/env bash

# star: /etc/traefik/etc/traefik/tls.yaml
#  cat ./tls.yaml
# tls:
#   stores:
#     default:
#       defaultCertificate:
#         certFile: ./etc/certs/domain.cert.pem
#         keyFile: ./etc/certs/private.key.pem

set -xeuo pipefail

# get package from porkbun shield little icon
#
# xaax.dev-ssl-bundle.zip

BUNDLEZIP=xaax.dev-ssl-bundle.zip
DOMCERT=domain.cert.pem
KEY=private.key.pem
PUBLICKEY=public.key.pem

cd ~/Downloads

[[ -r ./${BUNDLEZIP} ]] || {
  echo "missing ${BUNDLEZIP}"
  exit 1
}

[[ -d ${BUNDLEZIP%.*} ]] && rm -rf ./"${BUNDLEZIP%.*}"

unzip -- ./"${BUNDLEZIP}" || {
  echo "Error unzipping ${BUNDLEZIP}"
  exit 1
}

cd "${BUNDLEZIP%.*}"

cat "${DOMCERT}" "${KEY}" >|tls.pem

scp "${DOMCERT}" root@star:/apps/traefik/etc/certs/"${DOMCERT}"

scp "${KEY}" root@star:/apps/traefik/etc/certs/"${KEY}"
