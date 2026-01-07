# Ensure BASH environment

# Global settings

# Check if fzf is installed, exit if not
type aws &>/dev/null || {
  echo "awscli NOT FOUND. Skipping awscli configuration."
  return 0
}

export AWS_PROFILE=lab
export AWS_DEFAULT_REGION=us-east-1
export AwsRegion=us-east-1 # needed to set region for aliases when they expand. This will always be set in the current shell if this file loads
export MANINSTANCE=i-0a495644db9737bf6
#
# AWS Regions to check
REGIONS=("us-east-1" "us-west-2")
PROFILES=("net" "test" "dev" "production") # there is a 'man' for management

echo "$AWS_PROFILE"
echo "Region: $AWS_DEFAULT_REGION"
echo "Output: $AWS_DEFAULT_OUTPUT"
echo "Setting AWS_PROFILE to lab"

# Ensure AWS CLI autocompletion is enabled
if command -v aws_completer &>/dev/null; then
  complete -C "$(command -v aws_completer)" aws
fi


# alias awbedck="aws logs filter-log-events   --log-group-name /aws/bedrock/model-invocations   --start-time $(($(date +%s) - 3600))000   --region us-east-1   --profile test   --query 'events[].message'   --output json | jq -r '.[] | fromjson | .modelId' | sort | uniq -c"
alias awbedck="aws logs filter-log-events \
  --log-group-name /aws/bedrock/model-invocations \
  --start-time $(($(date +%s) - 3600))000 \
  --region us-east-1 \
  --profile test \
  --query 'events[].message' \
  --output json | jq -r '.[] | fromjson | .modelId' | sort | uniq -c"


alias awcd='cd ~/gitdir/aws'
alias cdaws='cd ~/gitdir/aws'
alias awcdskel='cd ~/gitdir/skel/bash/bashrc_zen.d/'
alias awcdeks='cd ~/gitdir/aws/PHRIBIGNETWORK/EKSALB/'
alias awvaws='nvim ~/gitdir/skel/bash/bashrc_zen.d/aws.sh'
alias awssh="aws ssm start-session --target ${MANINSTANCE} --region us-east-1 --profile net"
alias awdlb='aws elbv2 describe-load-balancers --query "LoadBalancers[].DNSName" --region us-east-1'
alias awlswaf="aws logs tail aws-waf-logs-HRI-APP-WAF   --follow   --region us-east-1   --profile net"
alias awlscreds='aws configure export-credentials --profile $AWS_PROFILE'


alias awlct="aws configure sso  --region ${AwsRegion:-us-east-1} --profile test"
alias awlcn="aws configure sso  --region $AwsRegion --profile net"
alias awlcd="aws configure sso  --region $AwsRegion --profile dev"
alias awlcp="aws configure sso  --region $AwsRegion --profile production"
alias awlcp="aws configure sso  --region $AwsRegion --profile man"

alias awlt="aws sso login --region ${AwsRegion:-us-east-1} --profile test --no-browser --use-device-code"
alias awltc="aws configure sso --region $AwsRegion --profile test --no-browser --use-device-code"
alias awln="aws sso login --region $AwsRegion --profile net --no-browser --use-device-code"
alias awlnc="aws configure sso --region $AwsRegion --profile net --no-browser --use-device-code"
alias awld="aws sso login --region $AwsRegion --profile dev --no-browser --use-device-code"
alias awlprod="aws sso login --region $AwsRegion --profile production --no-browser --use-device-code"
alias awlman="aws sso login --region $AwsRegion --profile man --no-browser --use-device-code"

alias bedtokens="aws cloudwatch get-metric-statistics   --namespace AWS/Bedrock   --metric-name InputTokenCount   --dimensions Name=ModelId,Value=us.anthropic.claude-sonnet-4-5-20250929-v1:0   --start-time $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S)   --end-time $(date -u +%Y-%m-%dT%H:%M:%S)   --period 300   --statistics Sum   --region us-east-1 --query 'Datapoints | sort_by(@, &Timestamp)'   --output table --profile test"
alias bedlogs='aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=Converse \
  --start-time $(date -u -d "24 hours ago" +%Y-%m-%dT%H:%M:%S) \
  --max-results 50 \
  --region us-east-1 \
  --profile test \
  --output json | jq -r '\''.Events | sort_by(.EventTime) | .[] | {time: .EventTime, event: .EventName, user: .Username, ip: (.CloudTrailEvent | fromjson | .sourceIPAddress), userAgent: (.CloudTrailEvent | fromjson | .userAgent)}'\'''

# Function: Get AWS Profile
#get_aws_context() {
#  local profile="$1"
#  if [[ -z "$profile" ]]; then
#    echo "Missing a profile name"
#    return 0
#  fi

INGRESS=ingo.healthresearch.org

tpisalapi() {
  nslookup "${INGRESS}" || {
    echo nslookup failed for "${INGRESS}"
    return 1
  }
  ret="$(curl -s https://"${INGRESS}"/pisalapi/api/v1/app/version)" || {
    echo ""
    echo ""
    echo "curl failed for ${INGRESS}"
    echo ""
    echo ""
    return 1
  }

  if command -v jq &>/dev/null; then
    echo "${ret}" | jq '.'
  else
    echo "${ret}"
  fi
}

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

hang_fire() {
  local StackName="$1"
  local StackAWSProfile="$2"
  local WaitTime=10

  ## Wait for net to finish
  aws cloudformation wait stack-create-complete \
    --stack-name "${StackName}" \
    --region us-east-1 --profile "${StackAWSProfile}"

  echo "Just completed ${StackName}"

  echo "Waiting for ${WaitTime}"

  sleep "${WaitTime}"

  set_stack_outputs "${StackName}" us-east-1 "${StackAWSProfile}"

  sleep 5
}

set_aws_envs() {

  echo " HRI-BIGNETWORK"
  set_stack_outputs HRI-BIGNETWORK us-east-1 net
  echo " HRI-BIGAWSDNS"
  set_stack_outputs HRI-BIGAWSDNS us-east-1 net
  echo " HRI-BIGDEV"
  set_stack_outputs HRI-BIGDEV us-east-1 dev
  echo " HRI-BIGTEST"
  set_stack_outputs HRI-BIGTEST us-east-1 test
  echo " HRI-BIGDATA"
  set_stack_outputs HRI-BIGDATA us-east-1 production # Mind the profile
# echo " HRI-BIGEKSALB"
# set_stack_outputs HRI-BIGEKSALB us-east-1 test # Mind the profile
  echo " BIG-ELBPUBLIC"
  set_stack_outputs BIG-ELBPUBLIC us-east-1 net # Mind the profile
  echo "HRI-EKS-VPC-TEST"
  set_stack_outputs HRI-EKS-VPC-TEST us-east-1 test
# echo "HRI-EKSALB-PRIVATE-TEST"
# set_stack_outputs HRI-EKSALB-PRIVATE-TEST us-east-1 test
  echo "HRI-BIGEKS-TEST"
  set_stack_outputs HRI-BIGEKS-TEST us-east-1 test
  echo "HRI-EKS-NLB-TEST"
  set_stack_outputs HRI-EKS-NLB-TEST us-east-1 test
# echo "HRI-EKS-CLUSTER-PROD"
# set_stack_outputs HRI-EKS-CLUSTER-PROD us-east-1 production
  echo "HRI-EKS-VPC-PROD"
  set_stack_outputs HRI-EKS-VPC-PROD us-east-1 production
# echo "HRI-EKSALB-PRIVATE-PROD"
# set_stack_outputs HRI-EKSALB-PRIVATE-PROD us-east-1 production
  echo "HRI-EKS-VPC-QA"
  set_stack_outputs HRI-EKS-VPC-QA us-east-1 test
  echo "HRI-BIGNETWORK-TGWRT-ASSC-EKSVPC-QA"
  set_stack_outputs HRI-BIGNETWORK-TGWRT-ASSC-EKSVPC-QA us-east-1 net
  echo "HRI-EKS-NLB-PROD production"
  set_stack_outputs HRI-EKS-NLB-PROD us-east-1 production
  echo "HRI-BIGEKS-QA"
  set_stack_outputs HRI-BIGEKS-QA us-east-1 test
# echo "HRI-EKSALB-PRIVATE-QA"
# set_stack_outputs HRI-EKSALB-PRIVATE-QA us-east-1 test
  echo "HRI-EKS-NLB-QA"
  set_stack_outputs HRI-EKS-NLB-QA us-east-1 test
  echo "HRI-INFRA-VPC-PROD"
  set_stack_outputs HRI-INFRA-VPC-PROD us-east-1 production
  echo "HRI-BIGNETWORK-TGWRT-ASSC-INFRA-VPC-PROD"
  set_stack_outputs HRI-BIGNETWORK-TGWRT-ASSC-INFRA-VPC-PROD us-east-1 net
  echo "HRI-ONE-VPC-PROD"
  set_stack_outputs HRI-ONE-VPC-PROD us-east-1 production
}

get_aws_context() {
  local profile="$1" # Correct: Local variable declared and assigned

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
  # Ensure get_aws_context is available and properly used
  local AwsProfile
  AwsProfile=$(get_aws_context "$@") || {
    echo "Error: Failed to retrieve AWS context. Check your inputs." >&2
    return 1
  }
  if [[ -z "$AwsRegion" ]]; then
    echo "Error: AwsRegion is not set. Ensure get_aws_context outputs it correctly." >&2
    return 1
  fi

  local vpcs
  vpcs=$(aws ec2 describe-vpcs \
    --region "$AwsRegion" \
    --profile "$AwsProfile" \
    --query 'Vpcs[].VpcId' \
    --output text 2>/dev/null) || {
    echo "Error: Failed to retrieve VPCs. Check your AWS CLI credentials and region." >&2
    return 1
  }

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
      --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PrivateIpAddress,PublicIpAddress]' \
      --output table 2>/dev/null) || {
      echo "  Error: Failed to retrieve instances for VPC $vpc_id." >&2
      continue
    }

    if [[ -z "$instances" || "$instances" == "None" ]]; then
      echo "  No EC2 instances found in this VPC."
    else
      echo "$instances"
    fi
    echo "-------------------------------------"
  done
}

# alsec2() {
#   AwsProfile=$(get_aws_context "$@")
#
#   local vpcs
#   vpcs=$(aws ec2 describe-vpcs \
#     --region "$AwsRegion" \
#     --profile "$AwsProfile" \
#     --query 'Vpcs[].VpcId' --output text)
#
#   if [[ -z "$vpcs" ]]; then
#     echo "No VPCs found in region $AwsRegion for profile $AwsProfile."
#     return 0
#   fi
#
#   echo "Listing EC2 instances for each VPC in region $AwsRegion using profile $AwsProfile:"
#   for vpc_id in $vpcs; do
#     echo "VPC: $vpc_id"
#     local instances
#     instances=$(aws ec2 describe-instances \
#       --filters "Name=vpc-id,Values=$vpc_id" \
#       --region "$AwsRegion" \
#       --profile "$AwsProfile" \
#       --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PrivateIpAddress]' \
#       --output table)
#     if [[ -z "$instances" ]]; then
#       echo "  No EC2 instances found in this VPC."
#     else
#       echo "$instances"
#     fi
#     echo "-------------------------------------"
#   done
# }
#
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
  AwsProfile=$(get_aws_context "$@")
  # jq -s (slurp the whole thing) reads in both objects and puts each into an array
  # Then, `.|add` combines the two JSON objects into one by merging their key-value pairs.
  # so one oject that combines the 'interesting' information
  aws sts get-caller-identity --region "${AwsRegion}" --profile "${AwsProfile}"
  aws iam list-account-aliases --region "${AwsRegion}" --profile "${AwsProfile}"

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

alsrdss() {

  AwsProfile=$(get_aws_context "$@")
  aws rds describe-db-snapshots \
    --profile "${AwsProfile}" \
    --query "DBSnapshots[*].[DBInstanceIdentifier, DBSnapshotArn]" \
    --output text

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

alsstsb() {
  local StackName AwsRegion="us-east-1" AwsProfile="default"
  if [[ $# -lt 1 ]]; then
    echo "Usage: alsstsb <stack-name> [aws-region] [aws-profile]"
    return 1
  fi
  StackName="$1"
  shift
  if [[ $# -gt 0 ]]; then
    AwsRegion="$1"
    shift
    if [[ $# -gt 0 ]]; then
      AwsProfile="$1"
    fi
  fi
  echo "Using Stack: $StackName, Region: $AwsRegion, Profile: $AwsProfile"
  aws cloudformation get-template --region "$AwsRegion" --profile "$AwsProfile" --stack-name "$StackName" --query 'TemplateBody' --output json | jq -r '.'
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
getpubs() {
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
  aws ec2 describe-instances \
    --filters "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].{
    Name: Tags[?Key==`Name`].Value | [0],
    InstanceId: InstanceId,
    Type: InstanceType,
    AZ: Placement.AvailabilityZone,
    PublicIP: PublicIpAddress || `No Public IP`,
    PrivateIP: PrivateIpAddress
  }' \
    --output table \
    --region us-east-1 \
    --profile "${AwsProfile}"
}

# Function to check resources for a given profile and region
check_resources() {

  local profile
  profile=$(get_aws_context "$@")

  local region="${AwsRegion}"

  echo "--------------------------------------------------"
  echo "Profile: $profile, Region: $region"
  echo "--------------------------------------------------"

  # EC2 Instances
  echo "Checking EC2 Instances..."
  aws ec2 describe-instances --region "$region" --profile "$profile" --output text | grep "INSTANCE.*STOPPED"

  # Unattached EBS Volumes
  echo "Checking Unattached EBS Volumes..."
  aws ec2 describe-volumes --region "$region" --profile "$profile" --filters "Name=status,Values=available" --output text

  # NAT Gateways (if you use them)
  echo "Checking NAT Gateways..."
  aws ec2 describe-nat-gateways --region "$region" --profile "$profile" --output text

  # Elastic Load Balancers
  echo "Checking Load Balancers..."
  aws elbv2 describe-load-balancers --region "$region" --profile "$profile" --output text

  # RDS Instances
  echo "Checking RDS Instances..."
  aws rds describe-db-instances --region "$region" --profile "$profile" --output text

  echo "" # Add a newline for readability
}

alslb() {

  local profile
  profile=$(get_aws_context "$@")
  local region="${AwsRegion}"

  # Get ALB ARN
  if ! ALB_ARN=$(aws elbv2 describe-load-balancers --names k8s-default-awsingre-32ebfbcf83 --query "LoadBalancers[0].LoadBalancerArn" --output text --region "${region}" --profile "${profile}" --no-cli-pager 2>/dev/null); then
    echo "Error: Failed to retrieve ALB ARN" >&2
    return 1
  fi

  # Check if ALB_ARN is empty
  if [[ -z "${ALB_ARN}" ]]; then
    echo "Error: No ALB found with the specified name" >&2
    return 1
  fi

  # Get listener ARNs for this ALB
  if ! LISTENER_ARNS=$(aws elbv2 describe-listeners --load-balancer-arn "${ALB_ARN}" --query "Listeners[*].ListenerArn" --output text --region "${region}" --profile "${profile}" --no-cli-pager 2>/dev/null); then
    echo "Error: Failed to retrieve listener ARNs" >&2
    return 1
  fi

  # Check if LISTENER_ARNS is empty
  if [[ -z "${LISTENER_ARNS}" ]]; then
    echo "Warning: No listeners found for the ALB" >&2
    return 0
  fi

  # For each listener, get the rules
  for LISTENER_ARN in ${LISTENER_ARNS}; do
    echo "Listener: ${LISTENER_ARN}"
    if ! aws elbv2 describe-rules --listener-arn "${LISTENER_ARN}" --region "${region}" --profile "${profile}" --no-cli-pager; then
      echo "Error: Failed to retrieve rules for listener ${LISTENER_ARN}" >&2
      # Continue with next listener instead of failing completely
    fi
  done
}

ssh-aws() {

  local aregion="${AWS_DEFAULT_REGION}"
  local aprofile=net

  aws sts get-caller-identity --region "${aregion}" --profile "${aprofile}"
  aws ec2 describe-instance-status --instance-ids "${MANINSTANCE}" --region "${aregion}" --profile "${aprofile}" || {
    echo "instanceid: ${MANINSTANCE} is not correct"
    return 1
  }

  aws ssm start-session --target "${MANINSTANCE}" --region "${aregion}" --profile "${aprofile}"

}

kci() {
  echo '
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
  name: ${GENERIC}
  namespace: default
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /${GENERIC}(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: ${GENERIC}
            port: 
              number: 80
' | GENERIC=mypath envsubst | kubectl create -f -
}

Install_kubectl_eksctl() {

  (
    cd /tmp || {
      echo "cd /tmp failed"
      exit 1
    }
    curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/arm64/kubectl &&
      sudo mv ./kubectl /usr/local/bin && sudo chmod +x /usr/local/bin/kubectl &&
      echo "*** Movedd kubectl to /usr/local/bin"

    # curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/arm64/kubectl.sha256
    # curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/arm64/kubectl
    # # for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
    ARCH=arm64
    PLATFORM=$(uname -s)_$ARCH

    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"

    # (Optional) Verify checksum
    curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep "${PLATFORM}" | sha256sum --check

    tar -xzf eksctl_"${PLATFORM}".tar.gz -C /tmp && rm eksctl_"${PLATFORM}".tar.gz

    echo "*** Moving eksctl to /usr/local/bin"

    sudo mv /tmp/eksctl /usr/local/bin && sudo chmod +x /usr/local/bin/eksctl
  )

}

tailwaf() {
  aws logs tail aws-waf-logs-HRI-APP-WAF \
    --follow \
    --region us-east-1 \
    --profile net |
    awk '{print substr($0, index($0, "{"))}' |
    jq -r --unbuffered '
    select(.action == "BLOCK" or (.nonTerminatingMatchingRules | length > 0) or .terminatingRuleId != "Default_Action") |
    
    (.timestamp / 1000 | strftime("%H:%M:%S")) as $time |
    ([.labels[]?.name | select(. and test("geo"))] | map(gsub("awswaf:clientip:geo:"; "")) | join(" | ")) as $geo |
    (.nonTerminatingMatchingRules | map(.ruleId) | join(", ")) as $matched |
    
    (if .action == "BLOCK" then "🚫"
     elif ($matched != "") then "👀"
     else "⚠️" end) as $icon |
    
    "\($icon) \($time) | \(.httpRequest.clientIp) | \($geo) | \(.action) | \(.terminatingRuleId) | \(.httpRequest.httpMethod) \(.httpRequest.uri)" +
    (if $matched != "" then " | Triggered: \($matched)" else "" end)
  '
}

awsdnscheck() {
  command -v cowsay &>/dev/null && cowsay "Herrrrrrre goes..."
  echo "#########################################"
  echo "Checking corp.healthresearch.org FORWARD DNS"
  echo "#########################################"
  nslookup alb-prd-dc-3.corp.healthresearch.org
  echo "#########################################"
  echo "Checking Single Label FORWARD DNS"
  echo "#########################################"
  nslookup alb-prd-dc-3
  echo "#########################################"
  echo "Checking corp.healthresearch.org REVERSE DNS"
  echo "#########################################"
  nslookup 10.1.100.100
  nslookup 10.1.100.101
  echo "#########################################"
  echo "Checking PING DNS name prem HRI alb-prd-dc-3"
  echo "#########################################"
  ping -l 1 -c 3 alb-prd-dc-3
  echo "#########################################"
  echo "Checking PING to on prem HRI DMZ alb-prd-dc-3"
  echo "#########################################"
  ping -l 1 -c 3 alb-prd-zdns-1
  echo "#########################################"
  echo "Checking PING to on prem HRI IP"
  echo "#########################################"
  ping -l 1 -c 2 10.1.100.100
  ping -l 1 -c 2 10.1.100.101
  echo "#########################################"
  echo "Checking PING to Internet IP"
  echo "#########################################"
  ping -l 1 -c 3 1.1.1.1
  echo "#########################################"
  echo "Checking PING to Internet DNS"
  echo "#########################################"
  ping -l 1 -c 3 www.cnn.com
  echo "#########################################"
  echo "Checking ssh"
  echo "#########################################"
  curl -s --connect-timeout 2 www.cnn.com:80 >/dev/null 2>&1 && echo "Connected to cnn 80"
}

alseni() {

  local profile
  profile=$(get_aws_context "$@")

  local region="${AwsRegion}"

  aws ec2 describe-network-interfaces \
    \
    --query 'NetworkInterfaces[*].{
    InterfaceId:NetworkInterfaceId,
    VpcId:VpcId,
    Description:Description,
    SecurityGroups:Groups[*].GroupName
  }' \
    --region "${region}" \
    --profile "${profile}" # --filters "Name=vpc-id,Values=vpc-12345678" \
}

# if the us. is missing, you get an inference error - "with on-demand throughput isn’t supported." put the `us.` at the beginning
askbed() {
  HAIKU=us.anthropic.claude-haiku-4-5-20251001-v1:0
  SONNET=us.anthropic.claude-sonnet-4-5-20250929-v1:0
  MODEL="${SONNET}"
  curl -X POST "https://bedrock-runtime.us-east-1.amazonaws.com/model/${MODEL}/converse" -H "Content-Type: application/json" -H "Authorization: Bearer $AWS_BEARER_TOKEN_BEDROCK" -d '{
    "messages": [
        {
            "role": "user",
            "content": [{"text": "This is a test message to see if I have connectivity and access. Please answer with a 'Ok'"}]
        }
    ]
  }'
}

