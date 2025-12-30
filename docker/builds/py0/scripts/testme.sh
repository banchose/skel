#!/usr/bin/env bash

set -xeuo pipefail

export AWS_PROFILE=test

touch ~/temp/testme
touch ~/testme
touch ~/work/testme
git --version
lsof -v
kubectl --client=true version
aws --version
cmake --version
claude --version
gcc --version
make --version
rustc --version
ipython --version
python3 --version
dig -v
jq --version
awk --version
curl --version | grep -q gnu
wget --version | grep -q GNU
go version
npm version
ip -br a

ping -c 3 1.1.1.1
curl -I www.google.com
curl -I www.cnn.com

# aws configure sso --region us-east-1 --profile test --no-browser --use-device-code
aws configure sso --region us-east-1 --profile net --no-browser --use-device-code
aws s3 ls --region us-east-1 --profile net
aws s3 ls --profile net
echo "########################################"
echo "#"
echo "#  Try aider ~/scripts/aider-run.sh"
echo "#   1. Modify and export AWS_BEARER_TOKEN_BEDROCK"
echo "#   2. export AWS_BEARER_TOKEN_BEDROCK="
echo "#   3. llm -m bedrock-claude-v4.5-sonnet -o bedrock_model_id us.anthropic.claude-sonnet-4-5-20250929-v1:0 \"This is a test. Respond with 'OK'\""
echo "#"
echo "########################################"
echo ""
echo ""
echo "########################################"
echo "#"
echo "#  Try claude"
echo "#"
echo "########################################"
~/work/aws/SSH-VIA-SSM.sh
