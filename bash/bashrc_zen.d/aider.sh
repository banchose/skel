[[ -z $ANTHROPIC_API_KEY ]] && echo "***** ANTHROPIC_API_KEY not set *****"
[[ -z $AWS_BEARER_TOKEN_BEDROCK ]] && echo "***** $AWS_BEARER_TOKEN_BEDROCK not set *****"
echo $ANTHROPIC_API_KEY
alias aider='aider --model bedrock/us.anthropic.claude-sonnet-4-5-20250929-v1:0'
alias aidera='aider --model sonnet --api-key anthropic="${ANTHROPIC_API_KEY}"'
alias aliasa2='aider --model  us.anthropic.claude-3-7-sonnet-20240620-v1:0'
