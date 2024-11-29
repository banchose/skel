# Ensure BASH environment
# This script is sourced to create the functions

# Global settings

export AWS_PROFILE=lab
export AWS_DEFAULT_REGION=us-east-1
export AwsRegion=us-east-1

echo "$AWS_PROFILE"
echo "Region: $AWS_DEFAULT_REGION"
echo "Output: $AWS_DEFAULT_OUTPUT"
echo "Setting AWS_PROFILE to lab"

# Ensure AWS CLI autocompletion is enabled
if command -v aws_completer &>/dev/null; then
  complete -C "$(command -v aws_completer)" aws
fi

# Function: Get AWS Profile
#get_aws_context() {
#  local profile="$1"
#  if [[ -z "$profile" ]]; then
#    echo "Missing a profile name"
#    return 0
#  fi

set_stack_outputs() {
  local stack_name="$1"
  local region="${2:-us-east-1}"
  local profile="${3:-default}"

  # Get all stack outputs
  local outputs_json
  outputs_json=$(aws cloudformation describe-stacks \
    --stack-name "$stack_name" \
    --query "Stacks[0].Outputs" \
    --output json \
    --region "$region" \
    --profile "$profile") || {
    echo "Error: Failed to retrieve stack outputs for '$stack_name'." >&2
    return 1
  }

  # Check if the outputs JSON is empty
  if [[ -z "$outputs_json" || "$outputs_json" == "[]" ]]; then
    echo "No outputs found for stack: $stack_name"
    return 1
  fi

  # Parse outputs using a Bash array
  local output_key output_value
  mapfile -t outputs < <(jq -r '.[] | "\(.OutputKey) \(.OutputValue)"' <<<"$outputs_json")

  for line in "${outputs[@]}"; do
    output_key="${line%% *}"
    output_value="${line#* }"

    # Export with a prefix to avoid namespace collisions
    export "$output_key=$output_value"

    # Print for verification (optional)
    echo "Exported $output_key=$output_value"
  done
}

set_aws_envs() {

  set_stack_outputs HRI-BIGNETWORK us-east-1 net
  set_stack_outputs HRI-BIGAWSDNS us-east-1 net
  set_stack_outputs HRI-BIGDEV us-east-1 dev
  set_stack_outputs HRI-BIGTEST us-east-1 test
}

get_aws_context() {
  local profile="$1" # Correct: Local variable declared and assigned
  local AwsRegion="us-east-1"

  local valid_profiles                          # Correct: Variable declared
  valid_profiles=$(aws configure list-profiles) # Correct: Command substitution is properly closed

  if [[ $? -ne 0 ]]; then # Correct: `if` properly formed
    echo "Error: Unable to fetch AWS profiles. Ensure the AWS CLI is installed and configured."
    return 1 # Correct: Use `return` in a function
  fi         # Correct: `if` block properly closed

  if [[ -z "$profile" ]]; then # Correct: Checks for empty string
    echo "Error: Missing profile name. Please provide a valid AWS profile."
    echo "Available profiles:"
    echo "$valid_profiles" # Correct: `echo` is fine here
    return 1
  fi

  if ! echo "$valid_profiles" | grep -qw "$profile"; then # Correct: Negation and piping syntax are fine
    echo "Error: Invalid profile '$profile'."             # Correct: Quotes around `$profile`
    echo "Available profiles:"
    echo "$valid_profiles"
    return 1
  fi

  echo "$profile" # Correct: Outputs the valid profile
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
  AwsProfile=$(get_aws_context "$@")

  aws ec2 describe-route-tables \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'RouteTables[*].[RouteTableId, VpcId, Tags[?Key==`Name`].Value | [0]]' \
    --output table
}

# Function: List Security Groups
alssg() {
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
# Function: List Instance Profiles
alsip() {
  AwsProfile=$(get_aws_context "$@")

  aws iam list-instance-profiles \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'InstanceProfiles[*].[InstanceProfileName, InstanceProfileId, Path]' \
    --output table
}

alsvpcs() {
  AwsProfile=$(get_aws_context "$@")

  echo "Listing all VPCs in region $AwsRegion for profile $AwsProfile:"

  aws ec2 describe-vpcs \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'Vpcs[*].[VpcId, CidrBlock, Tags[?Key==`Name`].Value | [0]]' \
    --output table
}

list_vpcs_with_subnets() {

  AwsProfile=$(get_aws_context "$@")

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
  AwsProfile=$(get_aws_context "$@")

  aws ec2 describe-launch-templates --query "LaunchTemplates[*].{TemplateName:LaunchTemplateName,TemplateID:LaunchTemplateId,Version:LatestVersionNumber}" --output table --profile "${AwsProfile}"
}

alsltd() {
  AwsProfile=$(get_aws_context "$@")

  aws ec2 describe-launch-template-versions --versions \$Latest --output yaml --profile "${AwsProfile}"

}

alsdlt() {
  AwsProfile=$(get_aws_context "$@")
  aws ec2 describe-launch-template-versions --versions \$Latest --query 'LaunchTemplateVersions[*].{Name:LaunchTemplateName,UserData:LaunchTemplateData.UserData}' --profile "${AwsProfile}" --output json | jq -r
}

alsltud() {
  AwsProfile=$(get_aws_context "$@")
  aws ec2 describe-launch-template-versions --versions \$Latest --query 'LaunchTemplateVersions[*].{Name:LaunchTemplateName,UserData:LaunchTemplateData.UserData}' --profile "${AwsProfile}" --output json |
    jq -r '
        .[] |
        select(.UserData != null) |
        "\(.Name):\nDecoded UserData:\n" + (.UserData | @base64d) + "\n-----------------------------"
    '
}
# Function: List Launch Templates
alslt() {
  AwsProfile=$(get_aws_context "$@")

  aws ec2 describe-launch-templates \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'LaunchTemplates[*].[LaunchTemplateId, LaunchTemplateName, LatestVersionNumber]' \
    --output table
}

alstg() {
  # Ensure AWS CLI is installed
  if ! command -v aws >/dev/null 2>&1; then
    echo "Error: AWS CLI is not installed. Please install it to use this function."
    return 1
  fi

  # Determine AWS profile using get_aws_context
  AwsProfile=$(get_aws_context "$@")
  if [[ $? -ne 0 || -z "${AwsProfile}" ]]; then
    echo "Failed to retrieve a valid AWS profile."
    return 1
  fi

  echo "Using AWS profile: ${AwsProfile}"

  # Fetch all Transit Gateways
  echo "Fetching Transit Gateways..."
  TransitGateways=$(aws ec2 describe-transit-gateways \
    --query "TransitGateways[].TransitGatewayId" \
    --output text \
    --profile "${AwsProfile}" 2>/dev/null)

  if [ -z "${TransitGateways}" ]; then
    echo "No Transit Gateways found for profile ${AwsProfile}."
    return 1
  fi

  # Loop through each Transit Gateway
  for TgwId in ${TransitGateways}; do
    echo "=================================================="
    echo "Transit Gateway: ${TgwId}"
    echo "=================================================="

    # Fetch Transit Gateway Attachments
    echo "Transit Gateway Attachments:"
    aws ec2 describe-transit-gateway-attachments \
      --filters "Name=transit-gateway-id,Values=${TgwId}" \
      --query "TransitGatewayAttachments[?ResourceType=='vpc'].{TransitGatewayId:TransitGatewayId, AttachmentId:TransitGatewayAttachmentId, VpcId:ResourceId, State:State}" \
      --output table \
      --profile "${AwsProfile}" || {
      echo "Error fetching Transit Gateway Attachments for ${TgwId}"
      continue
    }

    # Fetch VPCs and Names
    echo "Associated VPCs:"
    aws ec2 describe-vpcs \
      --query "Vpcs[].{VpcId:VpcId, VpcName:Tags[?Key=='Name'].Value | [0]}" \
      --output table \
      --profile "${AwsProfile}" || {
      echo "Error fetching VPCs for ${TgwId}"
      continue
    }

    # Fetch Transit Gateway Route Tables
    echo "Transit Gateway Route Tables:"
    aws ec2 describe-transit-gateway-route-tables \
      --filters "Name=transit-gateway-id,Values=${TgwId}" \
      --query "TransitGatewayRouteTables[].{RouteTableId:TransitGatewayRouteTableId, State:State}" \
      --output table \
      --profile "${AwsProfile}" || {
      echo "Error fetching Transit Gateway Route Tables for ${TgwId}"
      continue
    }
  done

  echo "Completed fetching details for all Transit Gateways."
  return 0
}

check_appliance_mode() {
  AwsProfile=$(get_aws_context "$@")
  local PROFILE="${AwsProfile}"
  local REGION=${2:-us-east-1}

  # Validate inputs
  if [[ -z "$PROFILE" ]]; then
    echo "Error: AWS profile is required. Pass it as the first parameter."
    return 1
  fi

  # Validate the region
  case "$REGION" in
  us-east-1 | us-east-2 | us-west-1 | us-west-2)
    # Valid region
    ;;
  *)
    echo "Error: Invalid AWS region: $REGION"
    echo "Valid regions are: us-east-1, us-east-2, us-west-1, us-west-2."
    return 1
    ;;
  esac

  echo "Fetching all Transit Gateway Attachments in region: $REGION using profile: $PROFILE"

  local attachments
  if ! attachments=$(aws ec2 describe-transit-gateway-attachments \
    --profile "${AwsProfile}" \
    --region "$REGION" \
    --query 'TransitGatewayAttachments[*].[TransitGatewayAttachmentId,ResourceId,ResourceType]' \
    --output text 2>&1); then
    echo "Error: Failed to fetch Transit Gateway Attachments. AWS CLI error: $attachments"
    return 1
  fi

  if [[ -z "$attachments" ]]; then
    echo "No Transit Gateway attachments found in region: $REGION using profile: $PROFILE"
    return 0
  fi

  printf "%-20s %-20s %-20s %-10s\n" "Attachment ID" "Resource ID" "Resource Type" "Appliance Mode"
  echo "-------------------------------------------------------------------------------------"

  while IFS=$'\t' read -r attachment_id resource_id resource_type; do
    local appliance_mode
    appliance_mode=$(aws ec2 describe-transit-gateway-vpc-attachments \
      --profile "$PROFILE" \
      --region "$REGION" \
      --transit-gateway-attachment-ids "$attachment_id" \
      --query 'TransitGatewayVpcAttachments[0].Options.ApplianceModeSupport' \
      --output text 2>/dev/null)
    appliance_mode=${appliance_mode:-UNKNOWN}
    printf "%-20s %-20s %-20s %-10s\n" "$attachment_id" "$resource_id" "$resource_type" "$appliance_mode"
    sleep 0.2 # Throttle API calls
  done <<<"$attachments"
}

# Example usage
# check_appliance_mode "my-aws-profile" "us-west-2"
#
#
##################################################################################

Get_SCPs_from_OU() {
  AwsProfile=$(get_aws_context "$@")
  AwsRegion="${AwsRegion:-us-east-1}"

  echo "Fetching policies attached to OU: $OU_ID..."

  # Fetch SCP IDs attached to the OU
  POLICY_IDS=$(aws organizations list-policies-for-target \
    --target-id "$OU_ID" \
    --filter SERVICE_CONTROL_POLICY \
    --profile "$PROFILE" \
    --query "Policies[].Id" \
    --output text --region "${AwsRegion}" --profile "${AwsProfile}")

  # Loop through each policy ID and fetch its JSON content
  for POLICY_ID in $POLICY_IDS; do
    echo "Fetching details for policy: $POLICY_ID..."
    aws organizations describe-policy \
      --policy-id "$POLICY_ID" \
      --profile "$PROFILE" \
      --query "Policy.Content" \
      --output json --region "${AwsRegion}" --profile "${AwsProfile}" | jq
    echo "----------------------------------------------------"
  done
}
