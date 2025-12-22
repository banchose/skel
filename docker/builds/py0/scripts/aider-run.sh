#!/usr/bin/env bash

set -xeuo pipefail

echo "###################################################################"
echo "#"
echo "# Set Bedrock API key: AWS_BEARER_TOKEN_BEDROCK"
echo "# Set the correct model name: bedrock/us.anthropic.claude-sonnet-4-5-20250929-v1:0"
echo "#"
echo "###################################################################"
echo ""
export AWS_BEARER_TOKEN_BEDROCK=ABSKQmVkcm9ja0FQSUtleS1oejUxLWF0LTQwNTM1MDAwNDQ4Mzp2OS9rWW5MM0RuTHlHdjkxc21SblR0K2UyV29IQys0L0s2eUwyTkFKdTBVOFpHMnl0a2lKSmZEZnVNZz0=
aider --dry-run --vim --dark-mode --no-auto-commits --show-diffs --model bedrock/us.anthropic.claude-sonnet-4-5-20250929-v1:0
