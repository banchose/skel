#!/bin/bash
# fast-vpc-create.sh - Create a VPC with two subnets and optional TGW attachment
# Usage: ./fast-vpc-create.sh [profile] [region] [tgw-id]

# Default values
PROFILE=${1:-"default"}
REGION=${2:-"us-east-1"}
TGW_ID=${3:-""}          # Optional transit gateway ID
PREFIX="fast-vpc-ea67bf" # Unique prefix no one else will use

echo "Creating resources with prefix: ${PREFIX}"
echo "Using profile: ${PROFILE}, region: ${REGION}"

### NOTE: Associate the instance profile with the instance

# aws ec2 associate-iam-instance-profile \
#     --instance-id i-0123456789abcdef0 \
#     --iam-instance-profile Name=your-instance-profile-name \
#     --profile awscliv2 \
#     --region us-east-1

# Create VPC
echo "Creating VPC..."
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.99.0.0/16 \
  --query Vpc.VpcId \
  --output text \
  --region "${REGION}" \
  --profile "${PROFILE}")

aws ec2 modify-vpc-attribute \
  --vpc-id "${VPC_ID}" \
  --enable-dns-hostnames \
  --region "${REGION}" \
  --profile "${PROFILE}"

aws ec2 modify-vpc-attribute \
  --vpc-id "${VPC_ID}" \
  --enable-dns-support \
  --region "${REGION}" \
  --profile "${PROFILE}"

# Tag VPC with our unique prefix
aws ec2 create-tags \
  --resources "${VPC_ID}" \
  --tags "Key=Name,Value=${PREFIX}" \
  --region "${REGION}" \
  --profile "${PROFILE}"

echo "Created VPC: ${VPC_ID}"

# Create Subnets
echo "Creating subnets..."
SUBNET1=$(aws ec2 create-subnet \
  --vpc-id "${VPC_ID}" \
  --cidr-block 10.99.1.0/24 \
  --availability-zone "${REGION}a" \
  --query Subnet.SubnetId \
  --output text \
  --region "${REGION}" \
  --profile "${PROFILE}")

aws ec2 create-tags \
  --resources "${SUBNET1}" \
  --tags "Key=Name,Value=${PREFIX}-subnet1" \
  --region "${REGION}" \
  --profile "${PROFILE}"

SUBNET2=$(aws ec2 create-subnet \
  --vpc-id "${VPC_ID}" \
  --cidr-block 10.99.2.0/24 \
  --availability-zone "${REGION}b" \
  --query Subnet.SubnetId \
  --output text \
  --region "${REGION}" \
  --profile "${PROFILE}")

aws ec2 create-tags \
  --resources "${SUBNET2}" \
  --tags "Key=Name,Value=${PREFIX}-subnet2" \
  --region "${REGION}" \
  --profile "${PROFILE}"

echo "Created subnets: ${SUBNET1}, ${SUBNET2}"

# If TGW_ID was provided, create attachment
# if [[ -n "${TGW_ID}" ]]; then
#   echo "Creating Transit Gateway attachment to ${TGW_ID}..."
#
#   ATTACHMENT_ID=$(aws ec2 create-transit-gateway-vpc-attachment \
#     --transit-gateway-id "${TGW_ID}" \
#     --vpc-id "${VPC_ID}" \
#     --subnet-ids "${SUBNET1}" "${SUBNET2}" \
#     --region "${REGION}" \
#     --profile "${PROFILE}" \
#     --query TransitGatewayVpcAttachment.TransitGatewayAttachmentId \
#     --output text)
#
#   aws ec2 create-tags \
#     --resources "${ATTACHMENT_ID}" \
#     --tags "Key=Name,Value=${PREFIX}-tgw-attach" \
#     --region "${REGION}" \
#     --profile "${PROFILE}"
#
#   echo "Created TGW attachment: ${ATTACHMENT_ID}"
# fi

echo "Summary of resources created:"
echo "VPC: ${VPC_ID} (tagged as ${PREFIX})"
echo "Subnet 1: ${SUBNET1} (tagged as ${PREFIX}-subnet1)"
echo "Subnet 2: ${SUBNET2} (tagged as ${PREFIX}-subnet2)"
if [[ -n "${TGW_ID}" ]]; then
  echo "TGW Attachment: ${ATTACHMENT_ID} (tagged as ${PREFIX}-tgw-attach)"
fi
echo "Run ./fast-vpc-destroy.sh ${PROFILE} ${REGION} to remove these resources"
