# Create test VPC and subnets
TEST_VPC=$(aws ec2 create-vpc \
  --cidr-block 10.99.0.0/16 \
  --query Vpc.VpcId \
  --output text \
  --region us-east-1 \
  --profile test)

SUBNET1=$(aws ec2 create-subnet \
  --vpc-id $TEST_VPC \
  --cidr-block 10.99.1.0/24 \
  --availability-zone us-east-1a \
  --query Subnet.SubnetId \
  --output text \
  --region us-east-1 \
  --profile test)

SUBNET2=$(aws ec2 create-subnet \
  --vpc-id $TEST_VPC \
  --cidr-block 10.99.2.0/24 \
  --availability-zone us-east-1b \
  --query Subnet.SubnetId \
  --output text \
  --region us-east-1 \
  --profile test)

# Try creating an attachment
aws ec2 create-transit-gateway-vpc-attachment \
  --transit-gateway-id tgw-06fe99b127d44f530 \
  --vpc-id $TEST_VPC \
  --subnet-ids $SUBNET1 $SUBNET2 \
  --region us-east-1 \
  --profile test
