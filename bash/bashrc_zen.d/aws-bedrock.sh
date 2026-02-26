# aws bedrock list-foundation-models --profile test | grep -iE '(opus|sonnet)'

export AWS_BEDROCK_SONNET_MODEL=us.anthropic.claude-sonnet-4-5-20250929-v1:0
echo "AWS_BEDROCK_SONNET_MODEL shell env set to ${AWS_BEDROCK_SONNET_MODEL}"
export AWS_BEDROCK_OPUS_MODEL=us.anthropic.claude-opus-4-1-20250805-v1:0
echo "AWS_BEDROCK_OPUS_MODEL shell env set to ${AWS_BEDROCK_OPUS_MODEL}"

# Set DEFAULT AWS Bedrock model env
export AWS_BEDROCK_DEFAULT_MODEL="${AWS_BEDROCK_SONNET_MODEL}"
echo "AWS_BEDROCK_DEFAULT_MODEL shell env set to ${AWS_BEDROCK_DEFAULT_MODEL}"

alias awlfmodels='aws bedrock list-foundation-models --region us-east-1 --profile test'
alias awlmodels='aws bedrock list-inference-profiles --region us-east-1 --profile test | grep inferenceProfileId:'

myclaude() {
  (
    if [[ -z "${AWS_BEARER_TOKEN_BEDROCK}" ]]; then
      echo "Error: AWS_BEARER_TOKEN_BEDROCK is not set." >&2
      exit 1
    fi

    unset ANTHROPIC_API_KEY
    export CLAUDE_CODE_USE_BEDROCK=1
    export AWS_REGION=us-east-1
    export ANTHROPIC_MODEL='us.anthropic.claude-opus-4-6-v1'
    claude "$@"
  )
}

get-prompt-default() {

  local prompt=~/gitdir/skel/PROMPT/DEFAULT_PROMPT_strict.txt

  [[ -f ${prompt} ]] && cat "${prompt}"

}
