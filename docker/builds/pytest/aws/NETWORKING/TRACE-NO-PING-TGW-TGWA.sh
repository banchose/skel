#!/bin/bash
echo "=== AWS Transit Gateway Troubleshooting for i-0a8183a9671a45dd2 ==="
echo "Instance IP: 172.22.195.249"
echo "VPC: vpc-0569f01a1503067da"
echo "Subnet: subnet-0454bdc8b67f8646b"
echo ""

# Set variables
VPC_ID="vpc-0569f01a1503067da"
SUBNET_ID="subnet-0454bdc8b67f8646b"
INSTANCE_ID="i-0a8183a9671a45dd2"

# Get route table for your subnet
ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=$SUBNET_ID" --query 'RouteTables[0].RouteTableId' --output text --profile test --region us-east-1)
echo "Route Table ID: $ROUTE_TABLE_ID"
echo ""

echo "=== YOUR VPC ROUTE TABLE ($ROUTE_TABLE_ID) ==="
aws ec2 describe-route-tables --route-table-ids $ROUTE_TABLE_ID --query 'RouteTables[0].Routes[].[DestinationCidrBlock,GatewayId,TransitGatewayId,State]' --output table --profile test --region us-east-1
echo ""

# Check VPC details
echo "=== VPC DETAILS ==="
aws ec2 describe-vpcs --vpc-ids $VPC_ID --query 'Vpcs[].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table --profile test --region us-east-1
echo ""

# Find Transit Gateway attachments
echo "=== TRANSIT GATEWAY ATTACHMENTS FOR YOUR VPC ==="
aws ec2 describe-transit-gateway-vpc-attachments --filters "Name=vpc-id,Values=$VPC_ID" --query 'TransitGatewayVpcAttachments[].[TransitGatewayAttachmentId,TransitGatewayId,VpcId,State,SubnetIds]' --output table --profile test --region us-east-1

# Get Transit Gateway ID
TGW_ID=$(aws ec2 describe-transit-gateway-vpc-attachments --filters "Name=vpc-id,Values=$VPC_ID" --query 'TransitGatewayVpcAttachments[0].TransitGatewayId' --output text --profile test --region us-east-1)
echo ""
echo "Transit Gateway ID: $TGW_ID"

if [ "$TGW_ID" != "None" ] && [ "$TGW_ID" != "" ]; then
  echo ""
  echo "=== TRANSIT GATEWAY DETAILS ==="
  aws ec2 describe-transit-gateways --transit-gateway-ids $TGW_ID --query 'TransitGateways[].[TransitGatewayId,State,DefaultRouteTableAssociation,DefaultRouteTablePropagation]' --output table --profile test --region us-east-1
  echo ""

  # Get Transit Gateway route table
  TGW_RT_ID=$(aws ec2 describe-transit-gateway-route-tables --filters "Name=transit-gateway-id,Values=$TGW_ID" --query 'TransitGatewayRouteTables[0].TransitGatewayRouteTableId' --output text --profile test --region us-east-1)
  echo "TGW Route Table ID: $TGW_RT_ID"
  echo ""

  echo "=== TRANSIT GATEWAY ROUTE TABLE ROUTES ==="
  aws ec2 search-transit-gateway-routes --transit-gateway-route-table-id $TGW_RT_ID --filters "Name=state,Values=active" --query 'Routes[].[DestinationCidrBlock,TransitGatewayAttachments[0].TransitGatewayAttachmentId,Type,State]' --output table --profile test --region us-east-1
  echo ""

  echo "=== ALL VPC ATTACHMENTS TO THIS TRANSIT GATEWAY ==="
  aws ec2 describe-transit-gateway-vpc-attachments --filters "Name=transit-gateway-id,Values=$TGW_ID" --query 'TransitGatewayVpcAttachments[].[VpcId,TransitGatewayAttachmentId,State,Tags[?Key==`Name`].Value|[0]]' --output table --profile test --region us-east-1
  echo ""

  echo "=== DETAILS OF OTHER ATTACHED VPCs ==="
  aws ec2 describe-transit-gateway-vpc-attachments --filters "Name=transit-gateway-id,Values=$TGW_ID" --query 'TransitGatewayVpcAttachments[].VpcId' --output text --profile test --region us-east-1 | tr '\t' '\n' | while read vpc; do
    if [ "$vpc" != "$VPC_ID" ]; then
      echo "VPC: $vpc"
      aws ec2 describe-vpcs --vpc-ids $vpc --query 'Vpcs[].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table --profile test --region us-east-1
    fi
  done
fi

echo ""
echo "=== SECURITY GROUPS FOR YOUR INSTANCE ==="
aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].SecurityGroups[].[GroupId,GroupName]' --output table --profile test --region us-east-1

# Get security group IDs
SECURITY_GROUPS=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].SecurityGroups[].GroupId' --output text --profile test --region us-east-1)

echo ""
echo "=== SECURITY GROUP OUTBOUND RULES ==="
for sg in $SECURITY_GROUPS; do
  echo "Security Group: $sg"
  aws ec2 describe-security-groups --group-ids $sg --query 'SecurityGroups[0].IpPermissionsEgress[].[IpProtocol,FromPort,ToPort,IpRanges[0].CidrIp,UserIdGroupPairs[0].GroupId]' --output table --profile test --region us-east-1
  echo ""
done

echo "=== SUBNET DETAILS ==="
aws ec2 describe-subnets --subnet-ids $SUBNET_ID --query 'Subnets[].[SubnetId,CidrBlock,AvailabilityZone,MapPublicIpOnLaunch]' --output table --profile test --region us-east-1
