#!/usr/bin/env bash

set -euo pipefail

helm upgrade ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  -f - <<EOF
controller:
  service:
    type: NodePort
    nodePorts:
      http: 32432
      https: 32589
EOF
