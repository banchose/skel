# Check for required environment variables
[[ -z $ANTHROPIC_API_KEY ]] && echo "***** ANTHROPIC_API_KEY not set *****" >&2
[[ -z $OPENROUTER_API_KEY ]] && echo "***** OPENROUTER_API_KEY not set *****" >&2
[[ -z $AWS_BEARER_TOKEN_BEDROCK ]] && echo "***** AWS_BEARER_TOKEN_BEDROCK not set *****" >&2
[[ -z $AWS_BEDROCK_DEFAULT_MODEL ]] && echo "***** AWS_BEDROCK_DEFAULT_MODEL is not set *****" >&2

export OPENROUTER_DEFAULT_MODEL=openrouter/anthropic/claude-sonnet-4.6
echo "EXPORTING OPENROUTER_DEFAULT_MODEL: ${OPENROUTER_DEFAULT_MODEL}"

alias llm_png='wl-paste | llm --at - image/png'
alias llm_or_srch='llm -m "${OPENROUTER_DEFAULT_MODEL}" -o online 1'

llm_set_openrouter_key() {
  [[ -z "${OPENROUTER_API_KEY}" ]] && {
    printf 'WARNING: OPENROUTER_API_KEY is not set\n' >&2
    return 1
  }
  printf '%s' "${OPENROUTER_API_KEY}" | llm keys set openrouter
}

llm_set_anthropic_key() {
  [[ -z "${ANTHROPIC_API_KEY}" ]] && {
    printf 'WARNING: ANTHROPIC_API_KEY is not set\n' >&2
    return 1
  }
  printf '%s' "${ANTHROPIC_API_KEY}" | llm keys set anthropic
}

llm_test_bedrock() {

  echo "checking llm default model"
  echo "----"
  llm models default
  echo "----"
  echo "llm cli keys are located:"
  echo "----"
  llm keys path
  echo "----"
  echo "llm cli keys set:"
  echo "----"
  llm keys
  echo "----"
  echo "AWS_BEARER_TOKEN_BEDROCK is set to ${AWS_BEARER_TOKEN_BEDROCK:0:8}"
  echo "AWS_BEDROCK_DEFAULT_MODEL is set to ${AWS_BEDROCK_DEFAULT_MODEL}"
  echo "----"
  llm "This is just a test. Please respond with a short acknowledgement" -m "${AWS_BEDROCK_DEFAULT_MODEL}"

}

llm_help() {

  cat <<'EOF'
printf '%s' "${ANTHROPIC_API_KEY}" | llm keys set anthropic  # secure pattern
llm keys list
llm keys path
llm keys get
llm keys set
llm logs status
llm logs          #  find conversation IDs
llm --cid <id>
llm logs list
llm logs on
llm logs off
llm models options
llm models list
llm models default # show the default model
llm models default MODEL # to set default model
llm -c # to continue chat
llm prompt --help
  --- custom functions ---
llmbed <prompt>               # prompt via Bedrock with date context
llm_set_bedrock_model         # set llm default model to AWS_BEDROCK_DEFAULT_MODEL
llm_set_openrouter_key        # load OPENROUTER_API_KEY into llm keys
llm_set_anthropic_key         # load ANTHROPIC_API_KEY into llm keys
llm_test_bedrock              # run diagnostics + test prompt via Bedrock
EOF

}

# Use a function instead of alias to capture date once
llmbed() {
  local current_date
  current_date=$(date)
  llm -s "It is currently ${current_date}. Please be accurate and concise." -m "${AWS_BEDROCK_DEFAULT_MODEL}" "$@"
}

llm_set_bedrock_model() {

  if [[ -z "${AWS_BEARER_TOKEN_BEDROCK+x}" ]]; then
    printf 'WARNING: AWS_BEARER_TOKEN_BEDROCK is not set\n' >&2
    return 1
  fi

  local token="${AWS_BEARER_TOKEN_BEDROCK}"
  local len="${#token}"

  if ((len > 16)); then
    printf 'AWS_BEARER_TOKEN_BEDROCK: %s…%s (len=%d)\n' \
      "${token:0:8}" "${token: -8}" "${len}" >&2
  else
    printf 'AWS_BEARER_TOKEN_BEDROCK: [token too short to truncate] (len=%d)\n' \
      "${len}" >&2
  fi

  llm models default "${AWS_BEDROCK_DEFAULT_MODEL}"
}
