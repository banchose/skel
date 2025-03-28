#
INSTANCEID=i-04aebda9960485984
AUSER=wjs04
# AUSER=ec2-user
AREGION=us-east-1
APROFILE=net

# aws sso login --profile "${APROFILE}"
# aws ec2 describe-instances --profile "${APROFILE}"
#
aws ec2 describe-instance-status --instance-ids "${INSTANCEID}" --profile "${APROFILE}" &>/dev/null || {
  echo "INSTANCEID: ${INSTANCEID} is not correct"
  return 1
}
ssh -i ~/Downloads/hri-MAIN-inspect.pem -o ProxyCommand="aws ssm start-session --target ${INSTANCEID} --document-name AWS-StartSSHSession --parameters 'portNumber=22' --region ${AREGION} --profile ${APROFILE}" "${AUSER}"@"${INSTANCEID}"

# 1. Add this to your ~/.ssh/config
#
# Host i-04aebda9960485984
#   ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=22' --region ${AREGION} --profile ${APROFILE}"
#
