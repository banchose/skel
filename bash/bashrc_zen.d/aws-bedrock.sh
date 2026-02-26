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

## llm cli  reference for bedfock and llm
## alias broT='llm -m bro -T Exa "This is just a test, respond with short acknowledgment"'
# -T tool because llm-exa or some such was installed: see llm tools list
# llm install llm-tools-exa
# llm install llm-tools-simpleeval
# llm install sqlite
# llm install llm-anthropic
# llm install llm-bedrock
# llm install llm-bedrock-anthropic
# llm install llm-templates-github
# llm install llm-templates-fabric
# llm install llm-fragments-github
# llm install llm-fragments-pdf
# llm install llm-fragments-site-text
# llm install llm-python
# llm install llm-jq
# llm install llm-cmd
# llm install llm-cmd-comp
# -m bro because bro is a config in ~/.config/io.datasette.llm/extra-openai-models.yaml
# symlinked to ~/skel/llm/litellm/extra-openai-models.yaml
# That contains yaml of a model_id: 'bro' (llm -m bro), and the connecting bedrock-sonnet (litellm)
# listening on the local host
# litellm -c /home/una/gitdir/skel/llm/litellm/litellm.conf --port 4000
alias broTs='llm -m bro -T Exa "This is just a test, Could you please test if you can search the web with a trivial seearch.Respond with short result message"'

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
