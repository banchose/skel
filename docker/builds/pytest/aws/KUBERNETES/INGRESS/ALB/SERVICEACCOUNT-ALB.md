# Service Account EKS

- Pods need to work with the AWS ALB
- To do that, Pods will use a service account created in kubernetes
- The Kubernetes service account will have a reference to the AWS ARN an AWS ROLE
- That ROLE is created with a permission policy AWS give you as json: aws-role.json 
- The ROLE permission policy allows things like creating listeners, ALB actions, etc
- That ROLE is assumed by ?? eks.amazonaws.com I think, home to the pods
- The kubernetes service account allows **processes** running in **Pods** to interact with the kubernetes api
- The aws load balancer controller (eksctl) creates the ServiceAccount
- `kind: ServiceAccount` in Kubernetes has an `annotations:` entry: `eks.amazonaws.com/role-arn`
- In the Pod yaml of the aws load balancer controller pod is a `ServiceAccount:` key that shows the name of the service account created

## Sonnet

# Service Account in EKS - How It Works

- Pods need to work with the AWS ALB (Application Load Balancer)
- To do that, Pods will use a service account created in Kubernetes
- The Kubernetes service account will have a reference to an AWS IAM Role ARN via an annotation
- That IAM ROLE is created with a permission policy AWS provides as JSON (often referenced as aws-load-balancer-controller-policy.json)
- The ROLE permission policy allows specific AWS API actions like creating listeners, managing ALBs, etc.
- The trust relationship of that ROLE is set to allow assumption by the OIDC provider of your EKS cluster (not eks.amazonaws.com)
- The Kubernetes service account allows **processes** running in **Pods** to interact with both:
  1. The Kubernetes API (standard Kubernetes functionality)
  2. AWS APIs (through the IRSA mechanism)

- The AWS Load Balancer Controller installation process creates both:
  - The IAM role with appropriate permissions
  - The Kubernetes ServiceAccount that references this role

- `kind: ServiceAccount` in Kubernetes has an `annotations:` entry: `eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME`

- In the Pod yaml of the AWS Load Balancer Controller, the `serviceAccountName:` field references the name of the created service account

- The EKS Pod Identity Webhook (running in your cluster) detects pods using this service account and injects AWS credentials as environment variables:
  - `AWS_ROLE_ARN`
  - `AWS_WEB_IDENTITY_TOKEN_FILE`

- The AWS SDK in the container automatically uses these environment variables to assume the IAM role and make authenticated AWS API calls

- eksctl is a tool that helps set up this entire chain, but it's not the controller itself. The actual controller running in your cluster is the AWS Load Balancer Controller (formerly called AWS ALB Ingress Controller)

This chain of trust allows pods to securely communicate with AWS services like Elastic Load Balancing without needing to store long-term AWS credentials in your Kubernetes manifests or container images.
