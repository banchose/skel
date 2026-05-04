#!/usr/bin/env bash

set -xeuo pipefail

openssl genrsa -out user1.key 2048 # has both pub/priv
# openssl rsa -in user1.key -pubout -out user1.pub

openssl req -new -key user1.key -out user1.csr -subj "/CN=user1/O=dev-team"

cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: user1-csr
spec:
  request: $(cat user1.csr | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

kubectl certificate approve user1-csr

kubectl get csr user1-csr -o jsonpath='{.status.certificate}' | base64 --decode >user1.crt

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: dev-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-role-binding
  namespace: default
subjects:
- kind: User
  name: user1
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: dev-role
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl config set-credentials user1 --client-certificate=user1.crt --client-key=user1.key
kubectl config set-cluster my-cluster --server=https:// <api-server-url >--certificate-authority=/path/to/ca.crt
kubectl config set-context user1-context --cluster=my-cluster --namespace=default --user=user1

kubectl config use-context user1-context
