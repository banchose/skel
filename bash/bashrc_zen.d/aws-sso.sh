SSO_INSTANCE_ARN="arn:aws:sso:::instance/ssoins-722356dbd9c212b8"

# Loop through each permission set to find BedrockDeveloperAccess
for PS_ARN in $(aws sso-admin list-permission-sets \
  --instance-arn $SSO_INSTANCE_ARN \
  --profile man \
  --query 'PermissionSets[]' \
  --output text); do

  NAME=$(aws sso-admin describe-permission-set \
    --instance-arn $SSO_INSTANCE_ARN \
    --permission-set-arn $PS_ARN \
    --profile man \
    --query 'PermissionSet.Name' \
    --output text)

  echo "Permission Set: $NAME"
  echo "  ARN: $PS_ARN"
  echo ""
done
