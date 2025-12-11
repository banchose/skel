aws eks describe-cluster --name EksSand --region us-east-1 --profile test \
  --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' --output text
