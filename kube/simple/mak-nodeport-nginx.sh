#!/usr/bin/env
#
set -euo pipefail

kubectl create deployment meenginx --image nginx -r 2

kubectl create service nodeport meenginx --tcp=8080:80 --node-port=30007

kubectl get nodes -o wide

# nodeIP=1.2.3.4
# Port=30007

curl -L "${nodeIP}:${Port}"

# kubectl get svc: you will see serviceport:nodeport
