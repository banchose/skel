#!/bin/bash
set -euo pipefail
#set -xeuo pipefail

# Variables
AXB_VPC_ID="${rEksVpc2}" # Secuirty Groups
AXB_VPC_CIDR="172.22.240.0/20"
AXB_AWSPROFILE="test"
AXB_AWSREGION="us-east-1"
AXB_CLUSTER_NAME="AXB_Cluster"
AXB_NODE_GROUP_NAME="${AXB_CLUSTER_NAME}-Nodes"
AXB_SUBNET_A="${rEksWorkloadPrivateSubnet2}"
AXB_SUBNET_B="${rEksWorkloadPrivateSubnetAZB2}"
CMDPAUSE=5
KUBEVERSION=1.32

# Die function for error handling
die() {
  local exit_code="${1:-1}"
  local message="${2:-Unknown error occurred}"
  echo "ERROR: ${message}" >&2
  exit "${exit_code}"
}

echo "####################################################################################"
echo ""
echo "Creating EKS control plane security group..."
echo ""
echo "####################################################################################"
echo ""
echo ""
echo "The AXB_CONTROL_PLANE_SG controls access to the Kubernetes API server"
echo "We will need to open port 443 for both admin users and worker nodes separately"
echo "This allows us to have two distinct access paths to the API server"
AXB_CONTROL_PLANE_SG=$(aws ec2 create-security-group \
  --group-name axb-control-plane-sg \
  --description "Security group for EKS control plane" \
  --vpc-id "${AXB_VPC_ID}" \
  --output text \
  --query 'GroupId' \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}")

[[ $? -eq 0 && -n "${AXB_CONTROL_PLANE_SG}" ]] || die 1 "Failed to create control plane security group"
echo "SUCCESS: Control Plane Security Group created: ${AXB_CONTROL_PLANE_SG}"

sleep "${CMDPAUSE}"

echo "####################################################################################"
echo ""
echo "Creating EKS worker node security group..."
echo ""
echo "####################################################################################"
echo ""
echo ""
echo "The AXB_WORKER_SG is applied to all worker nodes in the EKS cluster"
echo "It controls both node-to-node communication and control-plane-to-node communication"
echo "Nodes need this security group to talk to each other and receive commands from control plane"
AXB_WORKER_SG=$(aws ec2 create-security-group \
  --group-name axb-worker-sg \
  --description "Security group for EKS worker nodes" \
  --vpc-id "${AXB_VPC_ID}" \
  --output text \
  --query 'GroupId' \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}")

[[ $? -eq 0 && -n "${AXB_WORKER_SG}" ]] || die 1 "Failed to create worker node security group"
echo "SUCCESS: Worker Node Security Group created: ${AXB_WORKER_SG}"

sleep "${CMDPAUSE}"

echo "####################################################################################"
echo ""
echo "Creating Admin access security group for kubectl users..."
echo ""
echo "####################################################################################"
echo ""
echo ""
echo "The AXB_ADMIN_SG is for admin workstations and bastion hosts"
echo "Any instance with this security group will be able to use kubectl to access the cluster"
echo "This separates admin access from node access for better security"
AXB_ADMIN_SG=$(aws ec2 create-security-group \
  --group-name axb-admin-sg \
  --description "Security group for EKS administrative access" \
  --vpc-id "${AXB_VPC_ID}" \
  --output text \
  --query 'GroupId' \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}")

[[ $? -eq 0 && -n "${AXB_ADMIN_SG}" ]] || die 1 "Failed to create admin access security group"
echo "SUCCESS: Admin Access Security Group created: ${AXB_ADMIN_SG}"

sleep "${CMDPAUSE}"

echo "####################################################################################"
echo ""
echo " Configuring Admin API access (port 443) to control plane..."
echo ""
echo "####################################################################################"
echo ""
echo ""
echo "This rule allows kubectl access to the EKS API server (port 443)"
echo "We're using source-group to allow any instance in the AXB_ADMIN_SG to access the API"
echo "This is more precise than opening to the entire VPC CIDR and follows least privilege"
echo "Only instances with the admin security group can use kubectl, providing better control"
aws ec2 authorize-security-group-ingress \
  --group-id "${AXB_CONTROL_PLANE_SG}" \
  --protocol tcp \
  --port 443 \
  --source-group "${AXB_ADMIN_SG}" \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

# Open a hole for control plan api and kubectl
# aws ec2 authorize-security-group-ingress   --group-id "${AXB_CONTROL_PLANE_SG}"   --protocol tcp   --port 443   --cidr 172.22.34.173/32   --region "${AXB_AWSREGION}"   --profile "${AXB_AWSPROFILE}"

[[ $? -eq 0 ]] || die 1 "Failed to configure admin access to control plane security group"
echo "SUCCESS: Admin API access rule added to control plane security group"

sleep "${CMDPAUSE}"

echo "####################################################################################"
echo ""
echo " Configuring Node API access (port 443) to control plane..."
echo ""
echo "####################################################################################"
echo ""
echo ""
echo "This rule allows worker nodes to access the Kubernetes API server (port 443)"
echo "Worker nodes must talk to the API server to register, get pod specs, report status, etc."
echo "Without this rule, nodes cannot join the cluster or function properly"
echo "This is different from the admin access rule - nodes need their own path to the API server"
aws ec2 authorize-security-group-ingress \
  --group-id "${AXB_CONTROL_PLANE_SG}" \
  --protocol tcp \
  --port 443 \
  --source-group "${AXB_WORKER_SG}" \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

[[ $? -eq 0 ]] || die 1 "Failed to configure node access to control plane security group"
echo "SUCCESS: Node API access rule added to control plane security group"

sleep "${CMDPAUSE}"

echo "####################################################################################"
echo ""
echo " Configuring kubelet API access (port 10250) for worker nodes..."
echo ""
echo "####################################################################################"
echo ""
echo ""
echo "In the Worker nodes security group"
echo "Only allow 10250 from instances that are in the AXB_CONTROL_PLANE_SG"
echo "The Control plane is in the AXB_CONTROL_PLANE_SG"
echo "Port 10250 is used by kubelet on each node - the control plane uses this port to:"
echo " - Fetch pod logs (kubectl logs command)"
echo " - Execute commands in pods (kubectl exec)"
echo " - Port-forward to pods (kubectl port-forward)"
echo "Without this rule, many kubectl debugging commands would fail"
aws ec2 authorize-security-group-ingress \
  --group-id "${AXB_WORKER_SG}" \
  --protocol tcp \
  --port 10250 \
  --source-group "${AXB_CONTROL_PLANE_SG}" \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

[[ $? -eq 0 ]] || die 1 "Failed to configure kubelet API access rule"
echo "SUCCESS: Kubelet API access rule added to worker node security group"

sleep "${CMDPAUSE}"

echo "####################################################################################"
echo ""
echo "Configuring node-to-node communication for worker nodes..."
echo ""
echo "####################################################################################"
echo ""
echo ""
echo "This rule allows all traffic between worker nodes in the cluster"
echo "This is necessary for pod-to-pod communication across nodes"
echo "Without this rule, pods on different nodes couldn't talk to each other"
echo "We use --protocol all to allow both TCP and UDP traffic for all Kubernetes networking"
aws ec2 authorize-security-group-ingress \
  --group-id "${AXB_WORKER_SG}" \
  --protocol all \
  --source-group "${AXB_WORKER_SG}" \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

[[ $? -eq 0 ]] || die 1 "Failed to configure node-to-node communication rule"
echo "SUCCESS: Node-to-node communication rule added to worker node security group"

sleep "${CMDPAUSE}"

echo "####################################################################################"
echo ""
echo ""
echo ""
echo "All security group configurations completed successfully!"
echo ""
echo "Control Plane SG: ${AXB_CONTROL_PLANE_SG} - Used for the EKS API server access"
echo "Worker Node SG: ${AXB_WORKER_SG} - Used for all worker nodes in the cluster"
echo "Admin Access SG: ${AXB_ADMIN_SG} - Attach to admin instances that need kubectl access"
echo ""
echo "Security groups summary:"
echo "1. Control Plane SG (${AXB_CONTROL_PLANE_SG}):"
echo "   - Allows port 443 access from Admin SG (kubectl users)"
echo "   - Allows port 443 access from Worker Node SG (for node registration and operation)"
echo ""
echo "2. Worker Node SG (${AXB_WORKER_SG}):"
echo "   - Allows port 10250 access from Control Plane SG (for logs, exec, etc.)"
echo "   - Allows all traffic between nodes (for pod networking)"
echo ""
echo "3. Admin SG (${AXB_ADMIN_SG}):"
echo "   - Attach this to any instance that needs to run kubectl commands"
echo ""
echo "####################################################################################"
echo ""
echo " Create role"
echo ""
echo "####################################################################################"

# Create trust policy document for EKS cluster role
cat >eks-cluster-role-trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create trust policy document for EKS node role
cat >eks-node-role-trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create the EKS node role
aws iam create-role \
  --role-name AXB_EksNodeRole \
  --assume-role-policy-document file://eks-node-role-trust-policy.json \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

# Attach the AWS managed policies for EKS worker nodes
aws iam attach-role-policy \
  --role-name AXB_EksNodeRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

aws iam attach-role-policy \
  --role-name AXB_EksNodeRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

aws iam attach-role-policy \
  --role-name AXB_EksNodeRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

# Create the EKS cluster role
aws iam create-role \
  --role-name AXB_EksClusterRole \
  --assume-role-policy-document file://eks-cluster-role-trust-policy.json \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

# Attach the AWS managed policy for EKS clusters
aws iam attach-role-policy \
  --role-name AXB_EksClusterRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

echo ""
echo "####################################################################################"
echo ""
echo " Creating EKS cluster..."
echo ""
echo "####################################################################################"
echo ""
echo ""
echo "Creating EKS cluster named ${AXB_CLUSTER_NAME}"
echo "Using control plane security group: ${AXB_CONTROL_PLANE_SG}"
echo "Using worker node subnets from your VPC"
echo "This creates just the EKS control plane - we'll create nodes separately"
echo "The control plane takes 10-15 minutes to provision"

aws eks create-cluster \
  --name "${AXB_CLUSTER_NAME}" \
  --role-arn "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text --region "${AXB_AWSREGION}" --profile "${AXB_AWSPROFILE}"):role/AXB_EksClusterRole" \
  --resources-vpc-config '{
    "subnetIds": ["'"${AXB_SUBNET_A}"'", "'"${AXB_SUBNET_B}"'"],
    "securityGroupIds": ["'"${AXB_CONTROL_PLANE_SG}"'"],
    "endpointPrivateAccess": true,
    "endpointPublicAccess": false
  }' \
  --kubernetes-version "${KUBEVERSION}" \
  --no-cli-pager \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

[[ $? -eq 0 ]] || die 1 "Failed to create EKS cluster"echo "Waiting for EKS cluster to become active..."

echo ""
echo " Waiting on the creation of ${AXB_CLUSTER_NAME}"
echo ""

aws eks wait cluster-active \
  --name "${AXB_CLUSTER_NAME}" \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

echo "Cluster wait active ends..."

sleep $((3 * CMDPAUSE))

echo ""
echo ""
echo "####################################################################################"
echo ""
echo " Creating EKS node group..."
echo ""
echo "####################################################################################"
echo ""
echo ""
echo "Creating managed node group for cluster ${AXB_CLUSTER_NAME}"
echo "Using worker node security group: ${AXB_WORKER_SG}"
echo "Using subnets: ${AXB_SUBNET_A}, ${AXB_SUBNET_B}"
echo "This will provision actual EC2 instances that join your EKS cluster"
echo "The node group specifies the size, instance type, and scaling configuration"
echo "Node groups take 5-10 minutes to provision and join the cluster"

aws eks create-nodegroup \
  --cluster-name "${AXB_CLUSTER_NAME}" \
  --nodegroup-name "${AXB_NODE_GROUP_NAME}" \
  --node-role "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text --region "${AXB_AWSREGION}" --profile "${AXB_AWSPROFILE}"):role/AXB_EksNodeRole" \
  --subnets "${AXB_SUBNET_A}" "${AXB_SUBNET_B}" \
  --scaling-config '{
    "minSize": 2,
    "maxSize": 4,
    "desiredSize": 2
  }' \
  --instance-types t3.medium \
  --disk-size 20 \
  --ami-type AL2_x86_64 \
  --node-role "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text --region "${AXB_AWSREGION}" --profile "${AXB_AWSPROFILE}"):role/AXB_EksNodeRole" \
  --labels '{
    "role": "worker"
  }' \
  --no-cli-pager \
  --tags '{
    "Name": "'"${AXB_CLUSTER_NAME}"'-worker-node",
    "environment": "test"
  }' \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

echo "Node group provisioning is in progress and will take 5-10 minutes to complete"

echo "Waiting for EKS node group to become active..."
aws eks wait nodegroup-active \
  --cluster-name "${AXB_CLUSTER_NAME}" \
  --nodegroup-name "${AXB_NODE_GROUP_NAME}" \
  --region "${AXB_AWSREGION}" \
  --profile "${AXB_AWSPROFILE}"

[[ $? -eq 0 ]] || die 1 "Timeout or error waiting for EKS node group to become active"
echo "SUCCESS: EKS node group created"
