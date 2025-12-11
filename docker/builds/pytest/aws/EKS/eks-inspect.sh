#!/usr/bin/env bash

set -euo pipefail

# eks-network-map.sh - Complete network topology discovery tool

if [ $# -lt 1 ]; then
  echo "Usage: $0 <cluster-name> [profile] [region]"
  echo "Example: $0 EksTest test us-east-1"
  exit 1
fi

CLUSTER_NAME=${1:-EksTest}
AWS_PROFILE=${2:-test}
AWS_REGION=${3:-us-east-1}

# Colors for clarity
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}=== AWS Network Topology Map for EKS: $CLUSTER_NAME ===${NC}"
echo "Generated: $(date)"
echo ""
echo ""
echo "Using Cluster Name: $CLUSTER_NAME"
echo "Using AWS_REGION: $AWS_REGION"
echo "Using AWS_PROFILE: $AWS_PROFILE"
echo ""
echo ""
# First, get the VPC
VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME \
  --query 'cluster.resourcesVpcConfig.vpcId' \
  --output text \
  --region $AWS_REGION \
  --profile $AWS_PROFILE 2>/dev/null)

echo -e "${GREEN}VPC: $VPC_ID${NC}"
VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID \
  --query 'Vpcs[0].CidrBlock' \
  --output text \
  --region $AWS_REGION \
  --profile $AWS_PROFILE)
echo "CIDR: $VPC_CIDR"
echo ""

# Get ALL subnets in the VPC, organized by AZ
echo -e "${YELLOW}=== All Subnets in VPC ===${NC}"
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'sort_by(Subnets,&AvailabilityZone)[].[AvailabilityZone,SubnetId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' \
  --output text \
  --region $AWS_REGION \
  --profile $AWS_PROFILE | while read az subnet cidr name; do
  echo "  $az: $subnet - $cidr ($name)"
done
echo ""

# Network Load Balancers
echo -e "${YELLOW}=== Network Load Balancers ===${NC}"
aws elbv2 describe-load-balancers \
  --query "LoadBalancers[?VpcId=='$VPC_ID' && Type=='network'].[LoadBalancerName,LoadBalancerArn]" \
  --output text \
  --region $AWS_REGION \
  --profile $AWS_PROFILE | while read nlb_name nlb_arn; do

  echo -e "${CYAN}NLB: $nlb_name${NC}"

  # Get NLB IPs from ENIs
  aws ec2 describe-network-interfaces \
    --filters "Name=description,Values=*$nlb_name*" \
    --query 'NetworkInterfaces[].[AvailabilityZone,PrivateIpAddress,SubnetId]' \
    --output text \
    --region $AWS_REGION \
    --profile $AWS_PROFILE | while read az ip subnet; do
    echo "  $az: $ip (subnet: $subnet)"
  done

  # Get target groups
  echo "  Target Groups:"
  aws elbv2 describe-target-groups \
    --load-balancer-arn $nlb_arn \
    --query 'TargetGroups[].[TargetGroupName,Port,Protocol]' \
    --output text \
    --region $AWS_REGION \
    --profile $AWS_PROFILE | while read tg port proto; do
    echo "    - $tg (port $port/$proto)"
  done
  echo ""
done

# Application Load Balancers
echo -e "${YELLOW}=== Application Load Balancers ===${NC}"
aws elbv2 describe-load-balancers \
  --query "LoadBalancers[?VpcId=='$VPC_ID' && Type=='application'].[LoadBalancerName,Scheme,DNSName]" \
  --output text \
  --region $AWS_REGION \
  --profile $AWS_PROFILE | while read alb_name scheme dns; do

  echo -e "${CYAN}ALB: $alb_name ($scheme)${NC}"
  echo "  DNS: $dns"

  # Get ALB IPs from ENIs
  aws ec2 describe-network-interfaces \
    --filters "Name=description,Values=*$alb_name*" \
    --query 'NetworkInterfaces[].[AvailabilityZone,PrivateIpAddress,SubnetId]' \
    --output text \
    --region $AWS_REGION \
    --profile $AWS_PROFILE | while read az ip subnet; do
    echo "  $az: $ip (subnet: $subnet)"
  done
  echo ""
done

# EKS Nodes
echo -e "${YELLOW}=== EKS Nodes ===${NC}"
kubectl get nodes -o json | jq -r '.items[] | .metadata.name + "," + .spec.providerID' | while IFS=',' read node_name provider_id; do
  instance_id=$(echo $provider_id | cut -d'/' -f5)

  # Get instance details
  instance_info=$(aws ec2 describe-instances --instance-ids $instance_id \
    --query 'Reservations[0].Instances[0].[PrivateIpAddress,SubnetId,Placement.AvailabilityZone,InstanceType]' \
    --output text \
    --region $AWS_REGION \
    --profile $AWS_PROFILE)

  node_ip=$(echo $instance_info | awk '{print $1}')
  subnet_id=$(echo $instance_info | awk '{print $2}')
  az=$(echo $instance_info | awk '{print $3}')
  instance_type=$(echo $instance_info | awk '{print $4}')

  echo -e "${CYAN}Node: $node_name${NC}"
  echo "  Instance: $instance_id ($instance_type)"
  echo "  AZ: $az"
  echo "  Node IP: $node_ip"
  echo "  Subnet: $subnet_id"

  # Get all IPs on this node (including pod IPs)
  echo "  All IPs on this node:"
  aws ec2 describe-network-interfaces \
    --filters "Name=attachment.instance-id,Values=$instance_id" \
    --query 'NetworkInterfaces[].[NetworkInterfaceId,PrivateIpAddresses[].PrivateIpAddress]' \
    --output json \
    --region $AWS_REGION \
    --profile $AWS_PROFILE | jq -r '.[] | "    ENI: \(.[0])\n\(.[1][] | "      - \(.)")"'

  # Show pods on this node
  echo "  Pods running:"
  kubectl get pods -A --field-selector spec.nodeName=$node_name --no-headers | awk '{print "    - " $2 " (" $1 ")"}'
  echo ""
done

# EKS Nodes
# echo -e "${YELLOW}=== EKS Nodes ===${NC}"
# kubectl get nodes -o json | jq -r '.items[]' | while read -r node_json; do
#   node_name=$(echo "$node_json" | jq -r '.metadata.name')
#   provider_id=$(echo "$node_json" | jq -r '.spec.providerID')
#   instance_id=$(echo $provider_id | cut -d'/' -f5)
#
#   # Get instance details
#   instance_info=$(aws ec2 describe-instances --instance-ids $instance_id \
#     --query 'Reservations[0].Instances[0].[PrivateIpAddress,SubnetId,Placement.AvailabilityZone,InstanceType]' \
#     --output text \
#     --region $AWS_REGION \
#     --profile $AWS_PROFILE)
#
#   node_ip=$(echo $instance_info | awk '{print $1}')
#   subnet_id=$(echo $instance_info | awk '{print $2}')
#   az=$(echo $instance_info | awk '{print $3}')
#   instance_type=$(echo $instance_info | awk '{print $4}')
#
#   echo -e "${CYAN}Node: $node_name${NC}"
#   echo "  Instance: $instance_id ($instance_type)"
#   echo "  AZ: $az"
#   echo "  Node IP: $node_ip"
#   echo "  Subnet: $subnet_id"
#
#   # Get all IPs on this node (including pod IPs)
#   echo "  All IPs on this node:"
#   aws ec2 describe-network-interfaces \
#     --filters "Name=attachment.instance-id,Values=$instance_id" \
#     --query 'NetworkInterfaces[].[NetworkInterfaceId,PrivateIpAddresses[].PrivateIpAddress]' \
#     --output json \
#     --region $AWS_REGION \
#     --profile $AWS_PROFILE | jq -r '.[] | "    ENI: \(.[0])\n\(.[1][] | "      - \(.)")"'
#
#   # Show pods on this node
#   echo "  Pods running:"
#   kubectl get pods -A --field-selector spec.nodeName=$node_name --no-headers | awk '{print "    - " $2 " (" $1 ")"}'
#   echo ""
# done

# Other Important ENIs
echo -e "${YELLOW}=== Other Network Interfaces ===${NC}"
aws ec2 describe-network-interfaces \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'NetworkInterfaces[?Description!=`aws-K8S-`].[Description,InterfaceType,PrivateIpAddress,AvailabilityZone,Groups[0].GroupName]' \
  --output text \
  --region $AWS_REGION \
  --profile $AWS_PROFILE | grep -v "ELB\|K8S" | while read desc type ip az sg; do
  if [ ! -z "$desc" ] && [ "$desc" != "None" ]; then
    echo "  $desc: $ip (AZ: $az, Type: $type, SG: $sg)"
  fi
done | sort -u
echo ""

# Create a quick reference file
REFERENCE_FILE="network-map-${CLUSTER_NAME}-$(date +%Y%m%d-%H%M%S).txt"
echo -e "${GREEN}=== Quick Reference IPs ===${NC}"
{
  echo "# Network Quick Reference for $CLUSTER_NAME"
  echo "# Generated: $(date)"
  echo ""
  echo "# NLB IPs"
  aws ec2 describe-network-interfaces \
    --filters "Name=description,Values=*NLB*" "Name=vpc-id,Values=$VPC_ID" \
    --query 'NetworkInterfaces[].[PrivateIpAddress,Description]' \
    --output text \
    --region $AWS_REGION \
    --profile $AWS_PROFILE | while read ip desc; do
    echo "export NLB_IP_$(echo $desc | grep -oP '(?<=/).*?(?=/)' | tr '-' '_')=$ip"
  done

  echo ""
  echo "# EKS Node IPs"
  kubectl get nodes -o json | jq -r '.items[] | .metadata.name + "," + .spec.providerID' | while IFS=',' read node_name provider_id; do
    node_name_short=$(echo "$node_name" | cut -d'.' -f1)
    instance_id=$(echo $provider_id | cut -d'/' -f5)
    node_ip=$(aws ec2 describe-instances --instance-ids $instance_id \
      --query 'Reservations[0].Instances[0].PrivateIpAddress' \
      --output text \
      --region $AWS_REGION \
      --profile $AWS_PROFILE)
    echo "export EKS_NODE_${node_name_short//-/_}=$node_ip"
  done

  #   echo ""
  #   echo "# EKS Node IPs"
  #   kubectl get nodes -o json | jq -r '.items[]' | while read -r node_json; do
  #     node_name=$(echo "$node_json" | jq -r '.metadata.name' | cut -d'.' -f1)
  #     provider_id=$(echo "$node_json" | jq -r '.spec.providerID')
  #     instance_id=$(echo $provider_id | cut -d'/' -f5)
  #     node_ip=$(aws ec2 describe-instances --instance-ids $instance_id \
  #       --query 'Reservations[0].Instances[0].PrivateIpAddress' \
  #       --output text \
  #       --region $AWS_REGION \
  #       --profile $AWS_PROFILE)
  #     echo "export EKS_NODE_${node_name//-/_}=$node_ip"
  #   done

  echo ""
  echo "# Subnet IDs"
  aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'Subnets[].[SubnetId,Tags[?Key==`Name`].Value|[0]]' \
    --output text \
    --region $AWS_REGION \
    --profile $AWS_PROFILE | while read subnet name; do
    if [ ! -z "$name" ]; then
      echo "export SUBNET_${name//-/_}=$subnet"
    fi
  done
} | tee $REFERENCE_FILE

echo ""
echo -e "${GREEN}Reference saved to: $REFERENCE_FILE${NC}"
echo "Source it with: source $REFERENCE_FILE"

# Flow log helper
echo ""
echo -e "${BLUE}=== CloudWatch Insights Query for These IPs ===${NC}"
echo "Use this query to filter flow logs for your infrastructure:"
echo ""
cat <<'EOF'
fields @timestamp, srcaddr, dstaddr, srcport, dstport, protocol, action
| filter srcaddr in [
EOF

# Collect all IPs
ALL_IPS=$(
  # NLB IPs
  aws ec2 describe-network-interfaces \
    --filters "Name=description,Values=*NLB*" "Name=vpc-id,Values=$VPC_ID" \
    --query 'NetworkInterfaces[].PrivateIpAddress' \
    --output text \
    --region $AWS_REGION \
    --profile $AWS_PROFILE

  # Node IPs
  kubectl get nodes -o json | jq -r '.items[].status.addresses[] | select(.type=="InternalIP") | .address'
)

echo "$ALL_IPS" | tr ' ' '\n' | sort -u | sed 's/^/    "/;s/$/",/' | sed '$ s/,$//'

cat <<'EOF'
  ]
  or dstaddr in [
EOF

echo "$ALL_IPS" | tr ' ' '\n' | sort -u | sed 's/^/    "/;s/$/",/' | sed '$ s/,$//'

cat <<'EOF'
  ]
| sort @timestamp desc
| limit 100
EOF
