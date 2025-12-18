#!/usr/bin/env bash
set -euo pipefail

INSTPROFILE="CreateSSMtoExistingEc2-rSSMInstanceProfile-A7KOzjgxgggc"
INSTID="i-0b4c353d89e914907"
PROFILE=awscliv2
REGION=us-east-1

aws ec2 associate-iam-instance-profile \
  --instance-id "${INSTID}" \
  --iam-instance-profile Name="${INSTPROFILE}" \
  --profile "${PROFILE}" \
  --region "${REGION}"
