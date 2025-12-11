eksctl get iamidentitymapping --cluster EksTest \
  --region us-east-1 \
  --profile test

eksctl create iamidentitymapping \
  --cluster EksTest \
  --region us-east-1 \
  --arn arn:aws:iam::405350004483:role/AWSReservedSSO_rEKSDeveloperPermissionSet_509fcc0afc7a86a3 \
  --username eks-developer-role \
  --group system:masters \
  --region us-east-1 \
  --profile test

eksctl create iamidentitymapping \
  --cluster EksQa \
  --region us-east-1 \
  --arn arn:aws:iam::405350004483:role/AWSReservedSSO_rEKSDeveloperPermissionSet_509fcc0afc7a86a3 \
  --username eks-developer-role \
  --group system:masters \
  --profile test

# Remove users
eksctl delete iamidentitymapping \
  --cluster EksTest \
  --region us-east-1 \
  --arn ROLE_TO_REMOVE_ARN \
  --username role-name-to-remove
