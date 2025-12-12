#!/usr/bin/env bash

set -euo pipefail

INSTANCEID=i-0a495644db9737bf6
AUSER=wjs04
# AUSER=ec2-user
AREGION=us-east-1
APROFILE=net

echo "Checking if you are logged on to aws profile ${APROFILE}"
aws sts get-caller-identity --region "${AREGION}" --profile "${APROFILE}"

aws ec2 describe-instance-status --instance-ids "${INSTANCEID}" --region "${AREGION}" --profile "${APROFILE}" &>/dev/null || {
  echo "INSTANCEID: ${INSTANCEID} is not correct"
  return 1
}

aws ssm start-session --target "${INSTANCEID}" --region "${AREGION}" --profile "${APROFILE}"
