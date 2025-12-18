#!/usr/bin/env bash

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
unzip -- ./"${BUNDLEZIP}" || {
  echo "Error unzipping ${BUNDLEZIP}"
  exit 1
}
cd "${BUNDLEZIP%.*}"

cat "${DOMCERT}" "${KEY}" >|tls.pem

scp ./tls.pem root@ns2:/etc/pihole
