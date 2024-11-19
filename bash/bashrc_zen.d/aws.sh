# Ensure BASH environment

# Global settings

export AWS_PROFILE=lab
: "${AWS_DEFAULT_OUTPUT:=json}"
: "${AWS_DEFAULT_REGION:=us-east-1}"

echo "$AWS_PROFILE"
echo "Region: $AWS_DEFAULT_REGION"
echo "Output: $AWS_DEFAULT_OUTPUT"
echo "Setting AWS_PROFILE to lab"

# Ensure AWS CLI autocompletion is enabled
# if command -v aws_completer &>/dev/null; then
#  complete -C "$(command -v aws_completer)" aws
# fi

# Function: Get AWS Profile
get_aws_context() {
  local profile="$1"
  if [[ -z "$profile" ]]; then
    echo "Missing a profile name"
    return 1
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

alsid() {
  # jq -s (slurp the whole thing) reads in both objects and puts each into an array
  # Then, `.|add` combines the two JSON objects into one by merging their key-value pairs.
  # so one oject that combines the 'interesting' information
  {
    aws sts get-caller-identity &
    aws iam list-account-aliases
  } | jq -s ".|add"

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
}

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

alsltx() {

  aws ec2 describe-launch-templates --query "LaunchTemplates[*].{TemplateName:LaunchTemplateName,TemplateID:LaunchTemplateId,Version:LatestVersionNumber}" --output table --profile lab
}

alslt() {

  aws ec2 describe-launch-template-versions --versions \$Latest --output yaml

}

alsdlt() {
  aws ec2 describe-launch-template-versions --versions \$Latest --query 'LaunchTemplateVersions[*].{Name:LaunchTemplateName,UserData:LaunchTemplateData.UserData}' --output json | jq -r
}

alsdltud() {
  aws ec2 describe-launch-template-versions --versions \$Latest --query 'LaunchTemplateVersions[*].{Name:LaunchTemplateName,UserData:LaunchTemplateData.UserData}' --output json |
    jq -r '
        .[] |
        select(.UserData != null) |
        "\(.Name):\nDecoded UserData:\n" + (.UserData | @base64d) + "\n-----------------------------"
    '
}
