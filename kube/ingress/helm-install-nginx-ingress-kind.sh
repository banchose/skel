#!/usr/bin/env bash

set -xeuo pipefail

kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo update
# helm upgrade ingress-nginx ingress-nginx/ingress-nginx \
#   --install \
#   -n ingress-nginx \
#   -f - <<EOF
# controller:
#   service:
#     type: NodePort
#     nodePorts:
#       http: 32432
#       https: 32589
# EOF
