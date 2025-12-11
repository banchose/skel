#!/usr/bin/env bash

set -exuo pipefail

NAMESPACE=ingress-nginx

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --set controller.replicaCount=2 \
  --set controller.service.type=NodePort \
  --set controller.service.nodePorts.http=30080 \
  --set controller.service.nodePorts.https=30443

kubectl -n "${NAMESPACE}" rollout status deployment ingress-nginx-controller

sleep 10

kubectl get deployment -n "${NAMESPACE}" ingress-nginx-controller

sleep 5

kubectl create ns echo-server
kubectl create deployment echo-server --namespace echo-server --image=ealen/echo-server --replicas 2 --port 80
kubectl expose deployment echo-server --namespace echo-server --type ClusterIP --port 8080 --target-port 80
kubectl create ingress echo-server --namespace echo-server --rule=/echo-server=echo-server:8080 --class nginx
