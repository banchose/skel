#!/usr/bin/env bash

set -euo pipefail

kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec": {"type": "NodePort"}}'
