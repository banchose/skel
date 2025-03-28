AUSER=wjs04
INSTANCEID=i-04aebda9960485984
AREGION=us-east-1
APROFILE=net

scp -i ~/Downloads/hri-MAIN-inspect.pem \
  -o ProxyCommand="aws ssm start-session --target ${INSTANCEID} \
  --document-name AWS-StartSSHSession \
  --parameters 'portNumber=22' \
  --region ${AREGION} \
  --profile ${APROFILE}" \
  -r \
  ~/aws/PHRIBIGNETWORK/EKSALB2 "${AUSER}@${INSTANCEID}":~/temp
