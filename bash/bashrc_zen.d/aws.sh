# Ensure BASH environment

# Global settings

: "${AWS_DEFAULT_OUTPUT:=json}"
: "${AWS_DEFAULT_REGION:=us-east-1}"

# Ensure AWS CLI autocompletion is enabled
# if command -v aws_completer &>/dev/null; then
#  complete -C "$(command -v aws_completer)" aws
# fi

# Function: Get AWS Profile
get_aws_context() {
  local profile="$1"
  if [[ -z "$profile" ]]; then
    echo "default"
    return 0
  fi

  # Check if the provided profile exists
  if aws configure list-profiles | grep -q "^${profile}$"; then
    echo "$profile"
    return 0
  fi

  # Error handling for invalid profiles
  echo -e "\033[31mError: Cannot find profile '$profile'\033[0m"
  return 1
}

# Function: List CloudFormation stacks
alssts() {
  local AwsProfile AwsRegion="us-east-1"
  AwsProfile=$(get_aws_context "$@")

  aws cloudformation describe-stacks \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'Stacks[*].[StackName, StackStatus]' \
    --output table
}

# Function: List EC2 instances by VPC
alsec2() {
  local AwsProfile AwsRegion="us-east-1"
  AwsProfile=$(get_aws_context "$@")

  local vpcs
  vpcs=$(aws ec2 describe-vpcs \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'Vpcs[].VpcId' --output text)

  if [[ -z "$vpcs" ]]; then
    echo "No VPCs found in region $AwsRegion for profile $AwsProfile."
    return 0
  fi

  echo "Listing EC2 instances for each VPC in region $AwsRegion using profile $AwsProfile:"
  for vpc_id in $vpcs; do
    echo "VPC: $vpc_id"
    local instances
    instances=$(aws ec2 describe-instances \
      --filters "Name=vpc-id,Values=$vpc_id" \
      --region "$AwsRegion" \
      --profile "$AwsProfile" \
      --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PrivateIpAddress]' \
      --output table)
    if [[ -z "$instances" ]]; then
      echo "  No EC2 instances found in this VPC."
    else
      echo "$instances"
    fi
    echo "-------------------------------------"
  done
}

# Function: List Route Tables
alsrt() {
  local AwsProfile AwsRegion="us-east-1"
  AwsProfile=$(get_aws_context "$@")

  aws ec2 describe-route-tables \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'RouteTables[*].[RouteTableId, VpcId, Tags[?Key==`Name`].Value | [0]]' \
    --output table
}

# Function: List Security Groups
alssg() {
  local AwsProfile AwsRegion="us-east-1"
  AwsProfile=$(get_aws_context "$@")

  local security_groups
  security_groups=$(aws ec2 describe-security-groups \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'SecurityGroups[*]' \
    --output json)

  if [[ "$security_groups" == "[]" ]]; then
    echo "No security groups found in region $AwsRegion for profile $AwsProfile."
    return 0
  fi

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
alssn() {
  local AwsProfile AwsRegion="us-east-1"
  AwsProfile=$(get_aws_context "$@")

  aws ec2 describe-subnets \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'Subnets[*].[SubnetId, CidrBlock, VpcId, AvailabilityZone, Tags[?Key==`Name`].Value | [0]]' \
    --output table
}

# Function: List Launch Templates
alslt() {
  local AwsProfile AwsRegion="us-east-1"
  AwsProfile=$(get_aws_context "$@")

  aws ec2 describe-launch-templates \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'LaunchTemplates[*].[LaunchTemplateId, LaunchTemplateName, LatestVersionNumber]' \
    --output table
}

# Function: List Instance Profiles
alsip() {
  local AwsProfile AwsRegion="us-east-1"
  AwsProfile=$(get_aws_context "$@")

  aws iam list-instance-profiles \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'InstanceProfiles[*].[InstanceProfileName, InstanceProfileId, Path]' \
    --output table
}
