# aws bedrock list-foundation-models --profile test | grep -iE '(opus|sonnet)'
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
