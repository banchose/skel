# Otherwise, w3m opens if installed
export BROWSER=echo
# export AWS_PROFILE=lab
export AWS_DEFAULT_OUTPUT=json
export AWS_DEFAULT_REGION=us-east-1

if command -v aws_completer &>/dev/null; then
  complete -C "$(command -v aws_completer)" aws
fi
# AWS_ROLE_ARN
# AWS_ACCESS_KEY_ID
# AWS_CONFIG_FILE
# AWS_SECRET_ACCESS_KEY
# AWS_SESSION_TOKEN
