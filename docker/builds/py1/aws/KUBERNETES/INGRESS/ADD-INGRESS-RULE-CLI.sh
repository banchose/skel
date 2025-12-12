#!/usr/bin/env bash

set -ueo pipefail

kubectl create ingress echo-server --class=nginx --rule="/echo=echo-server:80" \
  --annotation nginx.ingress.kubernetes.io/rewrite-target: /$2 \
  --annotation nginx.ingress.kubernetes.io/use-regex: "true"
