#
#

# Check if fzf is installed, exit if not
type aws &>/dev/null || {
  echo "awscli NOT FOUND. Skipping awscli configuration."
  return 0
}

aws_get_SQLCMDPASS() {
  export SQLCMDPASSWORD=$(aws secretsmanager get-secret-value \
    --secret-id 'rds!db-40fa88b1-c790-4275-ab06-ef2e1ad0618a' \
    --region "${AWS_REGION:-us-east-1}" \
    --profile production \
    --query SecretString \
    --output text | jq -r '.password')

  echo "${SQLCMDPASSWORD}"
}

aws_get_SQLVERSION() {
  export SQLCMDPASSWORD=$(aws secretsmanager get-secret-value \
    --secret-id 'rds!db-40fa88b1-c790-4275-ab06-ef2e1ad0618a' \
    --region "${AWS_REGION:-us-east-1}" \
    --profile production \
    --query SecretString \
    --output text | jq -r '.password')

  sqlcmd -S sqlserver2022-instance.ctvplhh4dcnc.us-east-1.rds.amazonaws.com,1433 \
    -U adminuser \
    -C \
    -Q "SELECT @@VERSION;"
}

aws_get_SQLDBS() {
  export SQLCMDPASSWORD=$(aws secretsmanager get-secret-value \
    --secret-id 'rds!db-40fa88b1-c790-4275-ab06-ef2e1ad0618a' \
    --region "${AWS_REGION:-us-east-1}" \
    --profile production \
    --query SecretString \
    --output text | jq -r '.password')

  sqlcmd -S sqlserver2022-instance.ctvplhh4dcnc.us-east-1.rds.amazonaws.com,1433 \
    -U adminuser \
    -C \
    -Q "SELECT name FROM sys.databases;"

}
