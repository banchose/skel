#!/usr/bin/env bash

set -euo pipefail

kubectl run --rm -it --tty pingkungcurl1 \
  --image=curlimages/curl \
  --restart=Never \
  --timeout=30s \
  -- curl --connect-timeout 10 --max-time 30 10.244.69.251:5001

kubectl run -it --tty --image=bash:latest obash
kubectl attach obash -c obash -i -t

docker run -it --rm -v /path/to/script.sh:/script.sh:ro bash:latest bash /script.sh
