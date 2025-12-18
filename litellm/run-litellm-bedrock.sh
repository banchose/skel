#!/usr/bin/env bash

set -xeuo pipefail

export AWS_PROFILE=test
export AWS_REGION=us-east-1
export PORT=4000

echo ""
aws sts get-caller-identity --region "${AWS_REGION}" --profile "${AWS_PROFILE}"
echo ""

litellm --config ./litellm-bedrock-local.yaml --port "${PORT}" &

sleep 10

echo ""
echo ""
echo "Checking health"
curl -vL http://localhost:"${PORT}"/health
echo ""
echo ""
echo ""
curl -vL http://localhost:"${PORT}"/models
sleep 5
echo ""
echo ""
echo ""
echo "Testing a query..."
echo ""
echo ""
echo ""

curl -X POST http://localhost:"${PORT}"/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
   "model": "claude-4-5-sonnet",
   "messages": [
     {"role": "user", "content": "This is a test message.  Please respond with 'OK';"}
   ],
   "max_tokens": 100
 }'
