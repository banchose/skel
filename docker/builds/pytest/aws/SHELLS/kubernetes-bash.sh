#!/usr/bin/env bash

set -euo pipefail

CONNAME=bash-sh

## curl and bash
# kubectl run --rm -it --tty "${container-name}" \
#   --image=curlimages/curl \
#   --restart=Never \
#   --timeout=30s \
#   -- curl --connect-timeout 10 --max-time 30 10.244.69.251:5001

kubectl run -it --image=bash:latest "${CONNAME}"
# echo "To re-attach: kubectl attach ${CONNAME} -c ${CONNAME} -i -t"
