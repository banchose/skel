#!/usr/bin/env bash

set -euo pipefail

# kubectl run nginx-pod --image=nginx --restart=Never --port=80 -n default
# kubectl expose pod nginx-pod --type=NodePort --port=80 --name=nginx-service
kubectl expose pod nginx-pod --type=ClusterIP --port=80 --name=nginx-service
