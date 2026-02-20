awlbedrockaccess() {
  local sso_instance_arn="arn:aws:sso:::instance/ssoins-722356dbd9c212b8"

  # Loop through each permission set to find BedrockDeveloperAccess
  for PS_ARN in $(aws sso-admin list-permission-sets \
    --instance-arn $sso_instance_arn \
    --profile man \
    --query 'PermissionSets[]' \
    --output text); do

    NAME=$(aws sso-admin describe-permission-set \
      --instance-arn $sso_instance_arn \
      --permission-set-arn $PS_ARN \
      --profile man \
      --query 'PermissionSet.Name' \
      --output text)

    echo "Permission Set: $NAME"
    echo "  ARN: $PS_ARN"
    echo ""
  done
}
