#!/usr/bin/env bash

set -ueo pipefail

INSTANCEID=i-04aebda9960485984
ARegion=us-east-1
AProfile=net
SizeInGb=50

volume_to_expand="$(aws ec2 describe-instances --instance-ids "${INSTANCEID}" --query "Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId" --region ${ARegion} --profile "${AProfile}" --output text)"

aws ec2 modify-volume \
  --volume-id "${volume_to_expand}" \
  --size "${SizeInGb}" \
  --region "${ARegion}" \
  --profile "${AProfile}"

### Ec2
## Extend partition
# sudo growpart /dev/nvme0n1 1

## grow xfs to fill the extended partition
# sudo xfs_growfs -d /
