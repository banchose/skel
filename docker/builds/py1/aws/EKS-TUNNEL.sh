#!/usr/bin/env bash

# kubectl config set-cluster \
# arn:aws:eks:us-east-1:405350004483:cluster/EksTest \
# --server=https://localhost:8443 \
# --insecure-skip-tls-verify=true
#
# Connected through localhost via existing secure tunnel

# ~/gitdir/aws/TROUBLESHOOTING/EKS-TUNNEL.sh
set -euo pipefail

INSTANCEID=i-0a495644db9737bf6
AREGION=us-east-1
APROFILE=net
EKS_ENDPOINT="43003891DBB3CBD14160A984D6727493.gr7.us-east-1.eks.amazonaws.com"
LOCAL_PORT=8443

echo "Checking AWS SSO login for profile: ${APROFILE}"
aws sts get-caller-identity --profile "${APROFILE}" --region "${AREGION}" &>/dev/null || {
  echo "Please login first: aws sso login --profile ${APROFILE}"
  exit 1
}

echo "   Starting SSM tunnel to EKS cluster..."
echo "   Leave this running and use kubectl in another terminal"
echo "   Press Ctrl+C to close the tunnel"
echo ""
echo "######################################################"
echo "kubectl config set-cluster arn:aws:eks:us-east-1:405350004483:cluster/EksTest  --server=https://localhost:8443 --insecure-skip-tls-verify=true"
echo "######################################################"
aws ssm start-session \
  --target "${INSTANCEID}" \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"${EKS_ENDPOINT}\"],\"portNumber\":[\"443\"],\"localPortNumber\":[\"${LOCAL_PORT}\"]}" \
  --region "${AREGION}" \
  --profile "${APROFILE}"
