# Check for required environment variables
[[ -z $ANTHROPIC_API_KEY ]] && echo "***** ANTHROPIC_API_KEY not set *****" >&2
[[ -z $OPENROUTER_API_KEY ]] && echo "***** OPENROUTER_API_KEY not set *****" >&2
[[ -z $AWS_BEARER_TOKEN_BEDROCK ]] && echo "***** AWS_BEARER_TOKEN_BEDROCK not set *****" >&2
[[ -z $AWS_BEDROCK_DEFAULT_MODEL ]] && echo "***** AWS_BEDROCK_DEFAULT_MODEL is not set *****" >&2

# llm install llm-openrouter
# llm install llm-anthropic
# llm install llm-jq
# llm install llm-tools-simpleeval
# llm install llm-tools-sqlite
# llm install llm-tools-rag
# llm models list
# llm keys set anthropic -v
# llm keys set openrouter -v
# llm -f github:https://github.com/banchose/skel/blob/main/awk/awk.md "can you see this little awk snippet?"

export OPENROUTER_DEFAULT_MODEL=openrouter/anthropic/claude-sonnet-4.6
echo "EXPORTING OPENROUTER_DEFAULT_MODEL: ${OPENROUTER_DEFAULT_MODEL}"

export ANTHROPIC_DEFAULT_MODEL=anthropic/claude-sonnet-4-6
echo "EXPORTING ANTHROPIC_DEFAULT_MODEL: ${ANTHROPIC_DEFAULT_MODEL}"

alias llm_png='wl-paste | llm --at - image/png'
alias llm_ort_srch='llm -m "${OPENROUTER_DEFAULT_MODEL}" -o online 1'
alias llm_ort_srch_exa='llm -m "${OPENROUTER_DEFAULT_MODEL}" -T Exa'
alias llmos='llm -m "${OPENROUTER_DEFAULT_MODEL}" -o online 1'
alias llmose='llm -m "${OPENROUTER_DEFAULT_MODEL}" -T Exa'

# Anthropic
alias llm_ant_srch='llm -m "${ANTHROPIC_DEFAULT_MODEL}" -o online 1'
alias llm_ant_srch_exa='llm -m "${ANTHROPIC_DEFAULT_MODEL}" -T Exa'
alias llmas='llm -m "${ANTHROPIC_DEFAULT_MODEL}" -o online 1'
alias llmase='llm -m "${ANTHROPIC_DEFAULT_MODEL}" -T Exa'
alias llm_bash_script 'llm -f ~/gitdir/skel/PROMPT/SKILLS/bash_scripting_standards.txt -m "${ANTHROPIC_DEFAULT_MODEL}"'
alias llma='llm -t default -m "${ANTHROPIC_DEFAULT_MODEL}"'
# in template alias llma='llm -t default -T llm_version -T llm_time -T simple_eval -m "${ANTHROPIC_DEFAULT_MODEL}"'

llm_set_openrouter_key() {
  [[ -z "${OPENROUTER_API_KEY}" ]] && {
    printf 'WARNING: OPENROUTER_API_KEY is not set\n' >&2
    return 1
  }
  command llm keys set openrouter --value "${OPENROUTER_API_KEY}"
}

llm_set_anthropic_key() {
  [[ -z "${ANTHROPIC_API_KEY}" ]] && {
    printf 'WARNING: ANTHROPIC_API_KEY is not set\n' >&2
    return 1
  }
  command llm keys set anthropic --value "${ANTHROPIC_API_KEY}"
}

llm_set_default_template() {

  echo "Finding the templates path"
  local tpath="$(llm templates path)"
  echo "${tpath}"

  cp ~/gitdir/skel/llm/TEMPLATES/*.yaml "${tpath}"
}

llm_test_bedrock() {

  echo "checking llm default model"
  echo "----"
  command llm models default
  echo "----"
  echo "llm cli keys are located:"
  echo "----"
  command llm keys path
  echo "----"
  echo "llm cli keys set:"
  echo "----"
  command llm keys
  echo "----"
  echo "AWS_BEARER_TOKEN_BEDROCK is set to ${AWS_BEARER_TOKEN_BEDROCK:0:15}"
  echo "AWS_BEDROCK_DEFAULT_MODEL is set to ${AWS_BEDROCK_DEFAULT_MODEL}"
  echo "----"
  command llm "This is just a test. Please respond with a short acknowledgement" -m "${AWS_BEDROCK_DEFAULT_MODEL}"

}

llm_help() {

  cat <<'EOF'
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
llm logs -c --json --expand
llm models options
llm models list
llm models default # show the default model
llm models default MODEL # to set default model
llm chat -f my_doc.txt
llm -c # to continue chat
llm -f https://llm.datasette.io/robots.txt 'explain this'
llm -f cli.py 'a short snappy poem inspired by this code'
llm -f cli.py --sf explain_code.txt     # system prompt
llm fragments loaders         # github:
llm -f github:https://github.com/banchose/skel/blob/main/awk/awk.md "can you see this little awk snippet?"
llm -t fabric:summarize -f https://...
llm -f pdf:some.pdf
llm fragments
llm fragments -q pytest -q asyncio
llm fragments remove cli
llm -f fragment:
llm prompt --help
  --- custom functions ---
llmbed <prompt>                   # prompt via Bedrock with date context
===> llm_set_bedrock_model        # set llm default model to AWS_BEDROCK_DEFAULT_MODEL
===> llm_set_openrouter_key       # load OPENROUTER_API_KEY into llm keys
===> llm_set_anthropic_key        # load ANTHROPIC_API_KEY into llm keys
llm_test_bedrock                  # run diagnostics + test prompt via Bedrock
llm_status                        # Orienting what model and what keys are set 
EOF

}

# Use a function instead of alias to capture date once
llmbed() {
  local current_date
  current_date=$(date)
  command llm -s "It is currently ${current_date}. Please be accurate and concise." -m "${AWS_BEDROCK_DEFAULT_MODEL}" "$@"
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

  command llm models default "${AWS_BEDROCK_DEFAULT_MODEL}"
}

llm_status() {
  printf '=== default model ===\n'
  command llm models default
  printf '=== stored keys ===\n'
  command llm keys
  printf '=== env vars ===\n'
  printf 'ANTHROPIC_API_KEY:       %s\n' "${ANTHROPIC_API_KEY:0:15}"
  printf 'OPENROUTER_API_KEY:      %s\n' "${OPENROUTER_API_KEY:0:15}"
  printf 'AWS_BEARER_TOKEN_BEDROCK:%s\n' "${AWS_BEARER_TOKEN_BEDROCK:0:15}"
  printf 'AWS_BEDROCK_DEFAULT_MODEL:%s\n' "${AWS_BEDROCK_DEFAULT_MODEL:-not set}"
}
