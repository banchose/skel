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
gcc --version
make --version
rustc --version
dig -v
jq -v
awk
curl | grep -q gnu
wget --version | grep -q GNU
ip -br a

ping -c 3 1.1.1.1

aws sso login --no-browser --use-device-code
aws s3 ls
aws sso login --no-browser --use-device-code --profile net
aws s3 ls --profile net
~/work/aws/SSH-VIA-SSM.sh
