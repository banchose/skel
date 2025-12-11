#!/usr/bin/env bash

set -euo pipefail

INSTANCE=i-abc123...
AWSPROFILE=test
AWSREGION=us-east-1

kubectl config get-context
kubectl describe node "${INSTANCE}"

kubectl cordon "${INSTANCE}"
kubectl delete node "${INSTANCE}"

aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-name eks-rSandEksNodeGroup-e2cb48d3-4af4-a810-7b45-6a941b4333bb \
  --profile "${AWSPROFILE}" \
  --profile "${AWSREGION}"
