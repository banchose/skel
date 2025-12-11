#!/usr/bin/env bash

AWSPROFILE=lab3
AWSREGION=us-east-1

set -euo pipefail

ELBDNSNames="$(aws elbv2 describe-load-balancers --query "LoadBalancers[].LoadBalancerArn" --output text --region "${AWSREGION}" --profile "${AWSPROFILE}")"
[[ "$ELBDNSNames" != "None" ]] || {
  echo "No ELBs Found"
  exit 1
}

for elb in ${ELBDNSNames}; do
  echo "${elb}"
done
