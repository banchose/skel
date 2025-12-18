#!/usr/bin/env bash

set -ueo pipefail

cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
# extraPortMappings:
# - containerPort: 80
#   hostPort: 80
#   protocol: TCP
# - containerPort: 443
#   hostPort: 443
#   protocol: TCP
- role: worker
- role: worker
EOF

# three node (two workers) cluster config
# kind: Cluster
# apiVersion: kind.x-k8s.io/v1alpha4
# nodes:
# - role: control-plane
# - role: worker
# - role: worker

# cat <<EOF | ~/go/bin/kind create cluster --config=-
# kind: Cluster
# apiVersion: kind.x-k8s.io/v1alpha4
# networking:
#   apiServerAddress: "192.168.2.151"
#   apiServerPort: 6443
# nodes:
# - role: control-plane
#   kubeadmConfigPatches:
#   - |
#     kind: InitConfiguration
#     nodeRegistration:
#       kubeletExtraArgs:
#         node-labels: "ingress-ready=true"
#   extraPortMappings:
#   - containerPort: 80
#     hostPort: 80
#     protocol: TCP
#   - containerPort: 443
#     hostPort: 443
#     protocol: TCP
# - role: worker
# - role: worker
# EOF
