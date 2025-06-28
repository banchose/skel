# CONTROL PLANE ONLY - NO EXTRA NODES
# source ~/gitdir/skel/bash/bashrc_zen.d/kubernetes.sh
# source ~/gitdir/skel/bash/bashrc_zen.d/docker.sh
# go install sigs.k8s.io/kind
# ~/go/bin/kind get nodes
# ~/go/bin/kind get clusters
# ~/go/bin/kind create cluster
# kind create cluster # Default cluster context name is `kind`.
# kind create cluster --name kind-2
#
# cat <<EOF | kind create cluster --config=-
# kind: Cluster
# apiVersion: kind.x-k8s.io/v1alpha4
# nodes:
# - role: control-plane
#   extraPortMappings:
#   - containerPort: 80
#     hostPort: 80
#     protocol: TCP
#   - containerPort: 443
#     hostPort: 443
#     protocol: TCP
# EOF
#
# nodeSelector:
#   kubernetes.io/hostname: "kind-control-plane"
