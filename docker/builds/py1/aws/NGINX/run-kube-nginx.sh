#!/usr/bin/env bash

set -euo pipefail

# NODEIP=172.19.0.3
NODEIP=172.22.194.104
NODEPORT=30007
SERVICEPORT=8080
TARGETPORT=80
APPNAME=nginx-"${RANDOM}"

# kubectl get svc: you will see serviceport:nodeport

echo "Create a  "${APPNAME}" deployment"
kubectl create deployment "${APPNAME}" --image nginx -r 2
echo "Waiting for "${APPNAME}" deployment to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/"${APPNAME}"
echo "create the "${APPNAME}" service NodpPort"
kubectl create service nodeport "${APPNAME}" --tcp="${SERVICEPORT}:${TARGETPORT}" --node-port="${NODEPORT}"

echo "Waiting for "${APPNAME}" pods to be ready..."
kubectl wait --for=condition=ready pod -l app="${APPNAME}" --timeout=10s

kubectl get nodes -o wide

# Test nginx
curl -L "${NODEIP}:${NODEPORT}"
