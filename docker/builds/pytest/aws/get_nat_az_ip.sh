aws ec2 describe-nat-gateways \
  --profile net \
  --query "NatGateways[].{ID:NatGatewayId,IP:NatGatewayAddresses[0].PublicIp,SubnetId:SubnetId}" \
  --output json | jq -r '.[] | .ID + "," + .IP + "," + .SubnetId' |
  while IFS=, read -r id ip subnet; do
    az=$(aws ec2 describe-subnets --subnet-ids "$subnet" --query "Subnets[0].AvailabilityZone" --output text --profile net)
    echo "NAT: $id | IP: $ip | AZ: $az"
  done
