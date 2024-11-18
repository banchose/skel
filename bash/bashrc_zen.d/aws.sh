# Otherwise, w3m opens if installed
export BROWSER=echo
# export AWS_PROFILE=lab
export AWS_DEFAULT_OUTPUT=json
export AWS_DEFAULT_REGION=us-east-1

if command -v aws_completer &>/dev/null; then
  complete -C "$(command -v aws_completer)" aws
fi
# AWS_ROLE_ARN
# AWS_ACCESS_KEY_ID
# AWS_CONFIG_FILE
# AWS_SECRET_ACCESS_KEY
# AWS_SESSION_TOKEN
#!/usr/bin/env bash

# Function: Get AWS Profile and Region
get_aws_context() {
  local func_aws_profile
  if [ $# -ge 1 ]; then
    func_aws_profile="$1"
  elif [ -n "${AWS_PROFILE:-}" ]; then
    func_aws_profile="$AWS_PROFILE"
  else
    echo "Error: AWS profile not specified. Set the AWS_PROFILE environment variable or pass it as the first argument."
    return 1
  fi
  echo "$func_aws_profile"
}

AwsRegion="us-east-1"

# Function: List EC2 Instances by VPC
list_ec2_instances_by_vpc() {
  local AwsProfile
  AwsProfile=$(get_aws_context "$@") || return 1

  vpcs=$(aws ec2 describe-vpcs --query 'Vpcs[].VpcId' --output text --region "$AwsRegion" --profile "$AwsProfile")
  echo "Listing EC2 instances for each VPC in the region using profile: $AwsProfile"

  for vpc_id in $vpcs; do
    echo "VPC: $vpc_id"
    instances=$(aws ec2 describe-instances \
      --filters "Name=vpc-id,Values=$vpc_id" \
      --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PrivateIpAddress]' \
      --output table --region "$AwsRegion" --profile "$AwsProfile")
    if [ -z "$instances" ]; then
      echo "  No EC2 instances found in this VPC."
    else
      echo "$instances"
    fi
    echo "-------------------------------------"
  done
}

# Function: List Route Tables
list_route_tables() {
  local AwsProfile
  AwsProfile=$(get_aws_context "$@") || return 1

  echo "Listing all route tables in region $AwsRegion for profile $AwsProfile:"
  aws ec2 describe-route-tables --region "$AwsRegion" --profile "$AwsProfile" \
    --query 'RouteTables[*].{RouteTableId:RouteTableId, VpcId:VpcId, Name:Tags[?Key==`Name`].Value | [0]}' \
    --output table
}

# Function: List Security Groups and Rules
list_security_groups_and_rules() {
  local AwsProfile
  AwsProfile=$(get_aws_context "$@") || return 1

  security_groups=$(aws ec2 describe-security-groups --region "$AwsRegion" --profile "$AwsProfile" \
    --query 'SecurityGroups[*]' --output json)
  if [ "$security_groups" == "[]" ]; then
    echo "No security groups found in region $AwsRegion for profile $AwsProfile."
    return 0
  fi

  echo "Listing all security groups and their rules in region $AwsRegion for profile $AwsProfile:"
  echo "$security_groups" | jq -r '
    .[] |
    "Security Group:\n  GroupId: \(.GroupId)\n  GroupName: \(.GroupName // "No Name")\n  Inbound Rules:" +
    (if (.IpPermissions | length) > 0 then
      (.IpPermissions | map(
        "    - Protocol: \(.IpProtocol)\n      Ports: \((.FromPort // "All") | tostring)-\((.ToPort // "All") | tostring)\n      Sources: \((.IpRanges | map(.CidrIp) | join(", ")) // "None")"
      ) | join("\n"))
    else
      "\n    None"
    end) +
    "\n  Outbound Rules:" +
    (if (.IpPermissionsEgress | length) > 0 then
      (.IpPermissionsEgress | map(
        "    - Protocol: \(.IpProtocol)\n      Ports: \((.FromPort // "All") | tostring)-\((.ToPort // "All") | tostring)\n      Destinations: \((.IpRanges | map(.CidrIp) | join(", ")) // "None")"
      ) | join("\n"))
    else
      "\n    None"
    end)
  '
}

# Function: List Subnets
list_subnets() {
  local AwsProfile
  AwsProfile=$(get_aws_context "$@") || return 1

  echo "Listing all subnets in region $AwsRegion for profile $AwsProfile:"
  aws ec2 describe-subnets --region "$AwsRegion" --profile "$AwsProfile" \
    --query 'Subnets[*].{SubnetId:SubnetId, CidrBlock:CidrBlock, VpcId:VpcId, AvailabilityZone:AvailabilityZone, Name:Tags[?Key==`Name`].Value | [0]}' \
    --output table
}

# Function: List Transit Gateways and Attachments
list_transit_gateways_and_attachments() {
  local AwsProfile
  AwsProfile=$(get_aws_context "$@") || return 1

  transit_gateways=$(aws ec2 describe-transit-gateways --query 'TransitGateways[].TransitGatewayId' --output text --region "$AwsRegion" --profile "$AwsProfile")
  if [ -z "$transit_gateways" ]; then
    echo "No Transit Gateways found in region $AwsRegion for profile $AwsProfile."
    return 0
  fi

  for tgw_id in $transit_gateways; do
    echo "Transit Gateway: $tgw_id"

    route_tables=$(aws ec2 describe-transit-gateway-route-tables --region "$AwsRegion" --profile "$AwsProfile" \
      --filters "Name=transit-gateway-id,Values=$tgw_id" \
      --query 'TransitGatewayRouteTables[].TransitGatewayRouteTableId' \
      --output text)

    if [ -n "$route_tables" ]; then
      echo "  Route Tables:"
      for rt_id in $route_tables; do
        echo "    - $rt_id"
      done
    else
      echo "  - No Route Tables found"
    fi

    attachments=$(aws ec2 describe-transit-gateway-attachments --region "$AwsRegion" --profile "$AwsProfile" \
      --filters "Name=transit-gateway-id,Values=$tgw_id" \
      --query 'TransitGatewayAttachments[*].[TransitGatewayAttachmentId,ResourceType,ResourceId,State]' \
      --output table)

    if [ -n "$attachments" ]; then
      echo "  Attachments:"
      echo "$attachments"
    else
      echo "  - No Attachments found"
    fi
    echo "-------------------------------------"
  done
}

alssts() {
  local AwsProfile
  AwsProfile=$(get_aws_context "$@") || {
    echo "Can not find Profile"
    return 1
  }

  aws cloudformation describe-stacks \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'Stacks[*].[StackName, StackStatus]' \
    --output table

}

alsvpcs() {
  local AwsProfile
  AwsProfile=$(get_aws_context "$@") || {
    echo "Can not find Profile"
    return 1
  }

  echo "Listing all VPCs in region $AwsRegion for profile $AwsProfile:"

  aws ec2 describe-vpcs \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'Vpcs[*].[VpcId, CidrBlock, Tags[?Key==`Name`].Value | [0]]' \
    --output table

list_vpcs_with_subnets() {
  # Declare function variables
  local AwsProfile="${1:-default}"  # Default profile if not provided
  local AwsRegion="${2:-us-east-1}" # Default region if not provided

  # Fetch all VPCs
  local vpcs
  vpcs=$(aws ec2 describe-vpcs \
    --profile "$AwsProfile" \
    --region "$AwsRegion" \
    --query 'Vpcs[*].{VpcId:VpcId, CidrBlock:CidrBlock, Name: Tags[?Key==`Name`].Value | [0]}' \
    --output json) || {
    echo "Error fetching VPCs"
    return 1
  }

  # Check if VPCs exist
  if [[ "$vpcs" == "[]" ]]; then
    echo "No VPCs found in region $AwsRegion for profile $AwsProfile."
    return
  fi

  # Process each VPC
  echo "$vpcs" | jq -c '.[]' | while IFS= read -r vpc; do
    local vpc_id cidr name
    vpc_id=$(echo "$vpc" | jq -r '.VpcId')
    cidr=$(echo "$vpc" | jq -r '.CidrBlock')
    name=$(echo "$vpc" | jq -r '.Name // "No Name"')

    echo "VPC: $vpc_id ($cidr) - $name"

    # Fetch subnets for the current VPC
    local subnets
    subnets=$(aws ec2 describe-subnets \
      --filters "Name=vpc-id,Values=$vpc_id" \
      --profile "$AwsProfile" \
      --region "$AwsRegion" \
      --query 'Subnets[*].{SubnetId:SubnetId, CidrBlock:CidrBlock, Name: Tags[?Key==`Name`].Value | [0]}' \
      --output json) || {
      echo "  Error fetching subnets for VPC $vpc_id"
      continue
    }

    # Check if subnets exist
    if [[ "$subnets" == "[]" ]]; then
      echo "  No subnets found for this VPC."
    else
      # Process each subnet
      echo "$subnets" | jq -c '.[]' | while IFS= read -r subnet; do
        local subnet_id subnet_cidr subnet_name
        subnet_id=$(echo "$subnet" | jq -r '.SubnetId')
        subnet_cidr=$(echo "$subnet" | jq -r '.CidrBlock')
        subnet_name=$(echo "$subnet" | jq -r '.Name // "No Name"')

        echo "  Subnet: $subnet_id ($subnet_cidr) - $subnet_name"
      done
    fi
    echo "-------------------------------------"
  done
}
