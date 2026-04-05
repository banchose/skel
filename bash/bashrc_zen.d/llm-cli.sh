source ~/.bashrc_zen.d/api_keys_envs.sh

# Check for required environment variables
[[ -z "${ANTHROPIC_API_KEY:-}" ]] && echo "***** ANTHROPIC_API_KEY not set *****" >&2
[[ -z "${OPENROUTER_API_KEY:-}" ]] && echo "***** OPENROUTER_API_KEY not set *****" >&2
[[ -z "${AWS_BEARER_TOKEN_BEDROCK:-}" ]] && echo "***** AWS_BEARER_TOKEN_BEDROCK not set *****" >&2
[[ -z "${AWS_BEDROCK_DEFAULT_MODEL:-}" ]] && echo "***** AWS_BEDROCK_DEFAULT_MODEL is not set *****" >&2
[[ -z "${EXA_API_KEY:-}" ]] && echo "***** EXA_API_KEY not set *****" >&2

# command llm install llm-openrouter
# command llm install llm-anthropic
# command llm install llm-jq
# command llm install llm-docs
# command llm install llm-tools-simpleeval
# command llm install llm-tools-sqlite
# command llm install llm-tools-rag
# command llm models list
# command llm keys set anthropic --value
# command llm keys set openrouter --value
# command llm -f github:https://github.com/banchose/skel/blob/main/awk/awk.md "can you see this little awk snippet?"

### PATH llm cli to litellm to bedrock
# lbroT → command llm -m bro → extra-openai-models.yaml → LiteLLM (:4000) → Bedrock (via aws_profile_name: test)
# litellm runs locally 127.0.0.1:4000
# litellm.conf has
#       aws_region_name: us-east-1
#       aws_profile_name: test
# it can authenticate via logged in aws account

# llm() {
#   case "${1:-}" in
#   models | keys | logs | templates | aliases | fragments | tools | plugins | openai | embed* | chat | install | uninstall)
#     command llm "$@"
#     ;;
#   *)
#     local http_code
#     http_code=$(curl -s -o /dev/null -w '%{http_code}' \
#       --connect-timeout 2 --max-time 3 \
#       http://127.0.0.1:4000/health/liveliness 2>/dev/null) || true
#     if [[ "${http_code}" != "200" ]]; then
#       printf 'llm: litellm proxy not running on :4000\n' >&2
#       printf '     start: llm_start_litellm\n' >&2
#       return 1
#     fi
#     command llm -u -t brs "$@"
#     ;;
#   esac
# }

# alias llm='llm -t "${LLM_DEFAULT_TEMPLATE:-ants}"'
alias hk='llm -t ant-haiku'
alias llh='llmh -t ant-haiku'
alias llmdocs='llm -t ant-haiku -f docs: '

# alias llm='llm --ta -t "${LLM_DEFAULT_TEMPLATE:-ants}"'

alias llm-test='llm -t "${LLM_DEFAULT_TEMPLATE:-ants}" "${LLM_TEST_STRING_TOOLS}"'

alias llm_weather='llm -t weather-inline "what is the weather"'
alias llm_weather-d='llm -t Weatherman-anthropic "what is the weather" --td'

alias editllm-a='nvim -O ~/.config/io.datasette.llm/extra-openai-models.yaml ~/gitdir/skel/llm/litellm/litellm.conf'

alias editllm='nvim ~/gitdir/skel/bash/bashrc_zen.d/llm-cli.sh'
alias editlitellm='nvim ~/gitdir/skel/llm/litellm/litellm.conf'
alias editllmextra='nvim ~/gitdir/skel/llm/litellm/extra-openai-models.yaml'
alias editAichatconfig='nvim ~/data/aichat/config.yaml'

# In your shell rc
alias llm-find='command llm logs list -s -q' #"what ever you talked about"
alias llm-ids='command llm logs list --json -q'
# llm chat --cid abc123      # resume
# llm-ids "Exa" | jq -r '.[].conversation_id' | sort -u | head -n 1

alias llm_chat_tin_bash='llm chat -t tin --sf ~/gitdir/skel/PROMPT/DEFAULT_bash.md'

tf() {
  local log_file
  log_file="/tmp/tinfoil.$(date '+%s')"

  if ! curl -s --connect-timeout 4 http://localhost:8087 >/dev/null 2>&1; then
    tinfoil proxy \
      -r tinfoilsh/confidential-model-router \
      -e inference.tinfoil.sh \
      -p 8087 \
      >"${log_file}" 2>&1 &

    local -i attempts=0
    until curl -s --connect-timeout 1 http://localhost:8087 >/dev/null 2>&1; do
      ((++attempts))
      if ((attempts >= 10)); then
        printf 'tinfoil proxy did not become ready (log: %s)\n' "${log_file}" >&2
        return 1
      fi
      sleep 0.5
    done
  fi

  command llm "$@" -t tf_f --ta
}

tf() {
  if ! command -v tinfoil >/dev/null 2>&1; then
    printf >&2 'tf: tinfoil is not installed\n'
    read -rp 'Install tinfoil-cli? [y/N] ' answer
    if [[ ${answer,,} == y ]]; then
      curl -fsSL https://github.com/tinfoilsh/tinfoil-cli/raw/main/install.sh | sh
    else
      return 1
    fi
  fi

  local log_file
  log_file="/tmp/tinfoil.$(date '+%s')"

  if ! curl -s --connect-timeout 4 http://localhost:8087 >/dev/null 2>&1; then
    tinfoil proxy -r tinfoilsh/confidential-model-router -e inference.tinfoil.sh -p 8087 \
      >"${log_file}" 2>&1 &

    local -i attempts=0
    until curl -s --connect-timeout 1 http://localhost:8087 >/dev/null 2>&1; do
      ((++attempts))
      if ((attempts >= 10)); then
        printf >&2 'tinfoil proxy did not become ready (log: %s)\n' "${log_file}"
        return 1
      fi
      sleep 0.5
    done
  fi

  command llm "$@" -t tf_f --ta
}

## Python funcition example
# llm --functions '
# def evaluate(expression: str) -> str:
#     """Evaluate a mathematical expression"""
#     from simpleeval import simple_eval
#     return str(simple_eval(expression))
# ' "What is 2**32 divided by 7?" --td

# alias llm_curl_anthropic_models='curl https://api.anthropic.com/v1/models -H "x-api-key: $ANTHROPIC_API_KEY" -H "anthropic-version: 2023-06-01"'

alias llm_start_tinfoil_proxy='tinfoil proxy -r tinfoilsh/confidential-model-router -e inference.tinfoil.sh -p 8087'

export llmtst="this is just a test, can you search the web?"

echo "ENV: Setting CLAUDE_CODE_USE_BEDROCK=1"
export CLAUDE_CODE_USE_BEDROCK=1

export OPENROUTER_DEFAULT_MODEL=anthropic/claude-sonnet-4.6
echo "EXPORTING OPENROUTER_DEFAULT_MODEL: ${OPENROUTER_DEFAULT_MODEL}"

export ANTHROPIC_DEFAULT_MODEL=claude-sonnet-4-6
echo "EXPORTING ANTHROPIC_DEFAULT_MODEL: ${ANTHROPIC_DEFAULT_MODEL}"

export AWS_BEDROCK_DEFAULT_SONNET_MODEL=us.anthropic.claude-sonnet-4-5-20250929-v1:0
echo "EXPORTING AWS_BEDROCK_DEFAULT_SONNET_MODEL: ${AWS_BEDROCK_DEFAULT_SONNET_MODEL}"

export AWS_BEDROCK_DEFAULT_OPUS_MODEL=us.anthropic.claude-opus-4-1-20250805-v1:0
echo "EXPORTING AWS_BEDROCK_DEFAULT_OPUS_MODEL: ${AWS_BEDROCK_DEFAULT_OPUS_MODEL}"

export OPENROUTER_DEFAULT_SONNET_MODEL=openrouter/anthropic/claude-sonnet-4.6
echo "EXPORTING OPENROUTER_DEFAULT_SONNET_MODEL: ${OPENROUTER_DEFAULT_SONNET_MODEL}"

export OPENROUTER_DEFAULT_OPUS_MODEL=openrouter/anthropic/claude-opus-4.6
echo "EXPORTING OPENROUTER_DEFAULT_OPUS_MODEL: ${OPENROUTER_DEFAULT_OPUS_MODEL}"

export LTS="This is a test only. Repond only with 'OK'"
echo "EXPORTING LTS: ${LTS}"

llm_curl_anthropic_models() {
  curl https://api.anthropic.com/v1/models \
    -H "anthropic-version: 2023-06-01" \
    -H "X-Api-Key: ${ANTHROPIC_API_KEY}"
}

llm_curl_anthorpic_test() {
  curl -X POST https://api.anthropic.com/v1/chat/completions \
    -H "Authorization: Bearer ${ANTHROPIC_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful assistant."
    },
    {
      "role": "user",
      "content": "This is just a test. Please respond with a brief acknowledgment"
    }
  ],
  "model": "'"${ANTHROPIC_DEFAULT_MODEL:-claude-sonnet-4-6}"'",
  "max_tokens": 150,
  "temperature": 0.7
}'
}

## Openrouter

llm_curl_openrouter_models_count() {
  curl https://openrouter.ai/api/v1/models/count \
    -H "X-Api-Key: ${OPENROUTER_API_KEY}"
}

llm_curl_openrouter_models() {
  curl https://openrouter.ai/api/v1/models \
    -H "X-Api-Key: ${OPENROUTER_API_KEY}"
}

llm_curl_openrouter_test() {
  curl -X POST https://openrouter.ai/api/v1/chat/completions \
    -H "Authorization: Bearer ${OPENROUTER_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful assistant."
    },
    {
      "role": "user",
      "content": "This is just a test. Please respond with a brief acknowledgment"
    }
  ],
  "model": "'"${OPENROUTER_DEFAULT_MODEL:-anthropic/claude-sonnet-4-6}"'",
  "max_tokens": 150,
  "temperature": 0.7
}'
}

alias llm_start_litellm='litellm --config ~/gitdir/skel/llm/litellm/litellm.conf --port 4000 >/tmp/litellm-log-'"$(date '+%s')"' 2>&1 &'
alias llm_start_litellm_debug='litellm --config ~/gitdir/skel/llm/litellm/litellm.conf --port 4000 --detailed_debug'
alias cdllm='cd ~/.config/io.datasette.llm/'
alias cdllmt='cd ~/.config/io.datasette.llm/templates/'
alias cdllmS='cd ~/gitdir/skel/llm'
alias cdllmT='cd ~/gitdir/skel/llm/TEMPLATES'
alias cdlitellm='cd ~/gitdir/skel/llm/litellm/'

alias llm_test_litellm_get_local_models='curl -s -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" http://127.0.0.1:4000/v1/models'

alias llm_png='wl-paste | command llm --at - image/png'
alias llm_ort_srch='command llm -u -m "${OPENROUTER_DEFAULT_MODEL}" -o online 1'
alias llm_ort_srch_exa='command llm -u -m "${OPENROUTER_DEFAULT_MODEL}" -T Exa'
alias llmos='command llm -u -m "${OPENROUTER_DEFAULT_MODEL}" -o online 1'
alias llmose='command llm -u -m "${OPENROUTER_DEFAULT_MODEL}" -T Exa'
alias orts='command llm -u -m "${OPENROUTER_DEFAULT_MODEL}" -o online 1'
alias orte='command llm -u -m "${OPENROUTER_DEFAULT_MODEL}" -T Exa'
alias ort='command llm -u -m "${OPENROUTER_DEFAULT_MODEL}"'

# Anthropic
alias llm_ant_srch='command llm -u -m "${ANTHROPIC_DEFAULT_MODEL}" -T Exa'
alias llm_bash_script='command llm -u -f ~/gitdir/skel/PROMPT/SKILLS/bash_scripting_standards.txt -m "${ANTHROPIC_DEFAULT_MODEL}"'
alias llma='command llm -t default -m "${ANTHROPIC_DEFAULT_MODEL}"'
alias antx='command llm -u -m "${ANTHROPIC_DEFAULT_MODEL}"'
alias antxs='command llm -u -m "${ANTHROPIC_DEFAULT_MODEL}" -T Exa'
alias ant='command llm -t default_anthropic_sonnet'

# in template alias llma='llm -t default -T llm_version -T llm_time -T simple_eval -m "${ANTHROPIC_DEFAULT_MODEL}"'
#
alias llm_what_tools='command llm -t default_anthropic_sonnet "What tools to you have access to?"'
alias llm_what_version='command llm -t default_anthropic_sonnet "What LLM model version are you?"'

## AWS Bedrock aliases
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
#
#  Alias start
#
#
# alias broT='llm -u -m bro "This is just a test, respond with short acknowledgment"'
# alias bron='llm -u -m bro'
# alias bros='llm -u -m bro -T web_search -T simple_eval -T llm_version -T llm_time -T get_answer -T get_contents'
# # alias bro='llm -u -m bro -T Exa -T simple_eval -T llm_version -T llm_time -T get_answer -T get_contents'
# alias broc='llm chat -t bro'
alias bro='command llm -u -t bro'
# alias bro='echo "use llm"'
#
# alias brsT='llm -u -m brs "This is just a test, respond with short acknowledgment"'
# alias brsn='llm -u -m brs'
# alias brss='llm -u -m brs -T web_search -T simple_eval -T llm_version -T llm_time -T get_answer -T get_contents'
# # alias brs='llm -u -m brs -T Exa -T simple_eval -T llm_version -T llm_time -T get_answer -T get_contents'
# alias brsc='llm chat -t brs'
# alias brs='echo "use llm"'
alias brs='command llm -u -t brs'
#
# alias brhT='llm -u -m brh "This is just a test, respond with short acknowledgment"'
# alias brhn='llm -u -m brh'
# alias brhs='llm -u -m brh -T web_search -T simple_eval -T llm_version -T llm_time -T get_answer -T get_contents'

# alias brhc='llm chat -t brh'
alias brh='command llm -u -t brh'
# EXAMPLE alias brh='llm -u -m brh -T Exa -T simple_eval -T llm_version -T llm_time -T get_answer -T get_contents'
# alias brh='echo "use llm"'

# brs() {
#   local http_code
#
#   # 1. Check litellm proxy
#   http_code=$(curl -s -o /dev/null -w '%{http_code}' \
#     --connect-timeout 2 --max-time 3 \
#     http://127.0.0.1:4000/health 2>/dev/null) || true
#
#   if [[ "${http_code}" != "200" ]]; then
#     printf 'brs: litellm proxy is not running on :4000\n' >&2
#     printf '     start: llm_start_litellm\n' >&2
#     return 1
#   fi
#
#   # 2. Check AWS SSO session
#   if ! aws sts get-caller-identity --profile test &>/dev/null; then
#     printf 'brs: AWS SSO session expired or not logged in\n' >&2
#     printf '     run:   aws sso login --profile test\n' >&2
#     return 1
#   fi
#
#   # 3. All clear — run it
#   command llm -m brs "$@"
# }

llm_bootstrap() {
  local config_dir="${HOME}/.config/io.datasette.llm"
  local skel_dir="${HOME}/gitdir/skel/llm"

  mkdir -p "${config_dir}/templates"

  local f="extra-openai-models.yaml"
  if [[ -e "${config_dir}/${f}" || -L "${config_dir}/${f}" ]]; then
    printf 'skip: %s\n' "${f}"
  else
    printf 'link: %s\n' "${f}"
    ln -s "${skel_dir}/litellm/${f}" "${config_dir}/${f}"
  fi

  llm_symlink_templates
}

llm_symlink_templates() {
  local src_dir="${HOME}/gitdir/skel/llm/TEMPLATES"
  local dst_dir
  dst_dir="$(llm templates path)"
  local f
  for f in "${src_dir}"/*.yaml; do
    [[ -f "${f}" ]] || continue
    ln -sf "${f}" "${dst_dir}/"
  done
}

llm_set_openrouter_key() {
  [[ -z "${OPENROUTER_API_KEY:-}" ]] && {
    printf 'WARNING: OPENROUTER_API_KEY is not set\n' >&2
    return 1
  }
  command llm keys set openrouter --value "${OPENROUTER_API_KEY}"
}

llm_set_anthropic_key() {
  [[ -z "${ANTHROPIC_API_KEY:-}" ]] && {
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
  echo "AWS_BEARER_TOKEN_BEDROCK is set to ${AWS_BEARER_TOKEN_BEDROCK:+(${AWS_BEARER_TOKEN_BEDROCK:0:15}…)}"
  echo "AWS_BEDROCK_DEFAULT_MODEL is set to ${AWS_BEDROCK_DEFAULT_MODEL:-(not set)}"
  echo "----"
  command llm -u "This is just a test. Please respond with a short acknowledgement" -m "${AWS_BEDROCK_DEFAULT_MODEL:?AWS_BEDROCK_DEFAULT_MODEL is not set}"

}

# Use a function instead of alias to capture date once
llmbed() {
  local current_date
  current_date=$(date)
  command llm -s "It is currently ${current_date}. Please be accurate and concise." -m "${AWS_BEDROCK_DEFAULT_MODEL:?AWS_BEDROCK_DEFAULT_MODEL is not set}" "$@"
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

  command llm models default "${AWS_BEDROCK_DEFAULT_MODEL:?AWS_BEDROCK_DEFAULT_MODEL is not set}"
}

llm_set_exa_key() {
  [[ -z "${EXA_API_KEY:-}" ]] && {
    printf 'WARNING: EXA_API_KEY is not set\n' >&2
    return 1
  }
  command llm keys set exa --value "${EXA_API_KEY}"
}

echo "NOT SETTTING: Setting 'llm cli' API KEYs"
printf 'ANTHROPIC_API_KEY:       %s\n' "${ANTHROPIC_API_KEY:+(${ANTHROPIC_API_KEY:0:15}…)}"
printf 'OPENROUTER_API_KEY:      %s\n' "${OPENROUTER_API_KEY:+(${OPENROUTER_API_KEY:0:15}…)}"
printf 'EXA_API_KEY:             %s\n' "${EXA_API_KEY:+(${EXA_API_KEY:0:15}…)}"

START_LOCAL_LITELLM() {

  local LITELLM_CONFIG_DIR="$HOME/gitdir/skel/llm/litellm"
  local LITELLM_CONFIG="litellm.conf"
  local LITELLM_PORT=4000
  local AWS_PROFILE_NAME="test"

  echo "=== Starting LiteLLM Bedrock Proxy ==="

  # Check litellm exists
  command -v litellm >/dev/null 2>&1 || {
    echo "ERROR: litellm not found."
    echo "FIX:   pipx install 'litellm[proxy]'"
    return 1
  }

  # Check AWS auth is active
  if ! aws sts get-caller-identity --profile "${AWS_PROFILE_NAME}" >/dev/null 2>&1; then
    echo "ERROR: AWS session not active for profile '${AWS_PROFILE_NAME}'."
    echo "FIX:   aws sso login --profile ${AWS_PROFILE_NAME}"
    return 1
  fi
  echo "OK: AWS profile '${AWS_PROFILE_NAME}' authenticated."

  # Check port not already in use
  if ss -tlnp 2>/dev/null | grep -q ":${LITELLM_PORT} "; then
    echo "WARNING: Port ${LITELLM_PORT} already in use. LiteLLM may already be running."
    echo "         Check with: curl -s http://127.0.0.1:${LITELLM_PORT}/health"
    return 1
  fi

  # Check config exists
  if [[ ! -f "${LITELLM_CONFIG_DIR}/${LITELLM_CONFIG}" ]]; then
    echo "ERROR: Config not found: ${LITELLM_CONFIG_DIR}/${LITELLM_CONFIG}"
    return 1
  fi

  echo "Starting proxy on port ${LITELLM_PORT}..."
  echo "Stop with Ctrl+C"
  echo ""

  litellm -c "${LITELLM_CONFIG_DIR}/${LITELLM_CONFIG}" --port "${LITELLM_PORT}"
}
llm_status() {
  local -i issues=0
  local var val http_code
  local -a issue_msgs=()

  printf '=== default model ===\n'
  command llm models default

  printf '=== logging ===\n'
  command llm logs status

  printf '=== stored keys ===\n'
  command llm keys

  printf '=== stored templates ===\n'
  command llm templates

  printf '=== installed plugins ===\n'
  command llm plugins | python3 -c "
import sys, json
for p in json.load(sys.stdin):
    print(f\"  {p['name']:30s} {p.get('version', '?')}\")" 2>/dev/null ||
    printf '  (could not parse)\n'

  printf '=== env vars ===\n'
  for var in ANTHROPIC_API_KEY OPENROUTER_API_KEY AWS_BEARER_TOKEN_BEDROCK \
    AWS_BEDROCK_DEFAULT_MODEL EXA_API_KEY; do
    val="${!var:-}"
    if [[ -z "${val}" ]]; then
      printf '==> %-26s %s\n' "${var}:" "NOT SET"
      issue_msgs+=("${var} not set")
      ((issues++)) || true
    elif [[ "${#val}" -gt 20 ]]; then
      printf '    %-26s(%s…)\n' "${var}:" "${val:0:15}"
    else
      printf '    %-26s%s\n' "${var}:" "${val}"
    fi
  done

  printf '=== litellm proxy ===\n'
  http_code=$(curl -s -o /dev/null -w '%{http_code}' \
    --connect-timeout 2 --max-time 3 \
    http://127.0.0.1:4000/health 2>/dev/null) || true
  printf 'DEBUG: http_code=[%s]\n' "${http_code}" >&2
  if [[ "${http_code}" == "200" ]]; then
    printf '    127.0.0.1:4000 — UP\n'
  else
    printf '==> 127.0.0.1:4000 — DOWN\n'
    printf '    start: ~/gitdir/skel/llm/litellm/START_LOCAL_LITELLM.sh\n'
    printf '    or:    litellm -c ~/gitdir/skel/llm/litellm/litellm.conf --port 4000\n'
    issue_msgs+=("litellm proxy not running")
    ((issues++)) || true
  fi

  if ((issues > 0)); then
    printf '\n%d issue(s):\n' "${issues}"
    local msg
    for msg in "${issue_msgs[@]}"; do
      printf '  ==> %s\n' "${msg}"
    done
    return 1
  fi
  return 0
}

llm_get_host_info() {
  local -r marker="#### HOST INFO"
  printf '%s START\n\n' "${marker}"

  declare -f "${FUNCNAME[0]}"
  printf '\n'

  local -a sections=(
    "cat /etc/os-release"
    "hostname"
    "uname -a"
    "df -h"
    "ip a"
    "lscpu"
    "ping -w 4 -c 2 www.google.com"
    "cat /etc/resolv.conf"
    "curl -sS -o /dev/null -w 'http_code: %{http_code}\ntime: %{time_total}s\nip: %{remote_ip}\n' https://www.microsoft.com"
    "curl -sS -o /dev/null -w 'http_code: %{http_code}\ntime: %{time_total}s\nip: %{remote_ip}\n' https://www.cnn.com"
  )

  local cmd
  for cmd in "${sections[@]}"; do
    printf -- '--- %s ---\n' "${cmd}"
    eval "${cmd}" 2>&1 || true
    printf '\n'
  done

  printf '%s END\n' "${marker}"
}

llm_check_local_litellm() {
  local litellm_port=4000
  local litellm_host=localhost
  printf '%s\n' "Checking ${litellm_host}:${litellm_port}"
  curl -sS -o /dev/null -w 'http_code: %{http_code}\ntime: %{time_total}s\nip: %{remote_ip}\n' \
    "${litellm_host}:${litellm_port}/health" &&
    return 0 || return 1
}

llm-old() {
  local litellm_port=4000
  local litellm_host=localhost
  curl -s localhost:4000 &>/dev/null || {
    echo "Yo!!!   LitelLLM is DOWN: run llm_start_litellm"
    return 1
  }
  command llm -u -t brs "$@"

}

llme_test_embed_example() {
  (
    cd ~/temp/tinfoil-docs # && llm collections delete tinfoil
    # llm embed-multi tinfoil -m mini-l12 --files ./ '*.md' --store
    llm embed-multi tinfoil -m mpnet --files ./ '*.md' --store
  )
}

llm_help_anthropic_api_key_changed() {

  cat <<'EOF'
Change on host **star** in
  /apps/OpenWebUI/.env # systemd unit might start and not me with api key loaded
  ~/.bashrc_zen.d/apikeys.sh
EOF
}

llm_test_anthropic_query() {
  curl https://api.anthropic.com/v1/messages \
    -H "Content-Type: application/json" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -d '{
    "model": "claude-opus-4-6",
    "max_tokens": 1000,
    "messages": [
      {
        "role": "user",
        "content": "This is just a test to see if this is working, please respond with 'OK'"
      }
    ]
  }'
}

llm_help() {

  cat <<'EOF'
llm prompt --help    # Help on the flags
alias brs='llm -m brs -T Exa -T simple_eval -T llm_version -T llm_time -T get_answer -T get_contents'
--td, --tool-debug
--ta, --tool-approve
-u, --usage
-T, --tool
-sf, --system-fragment
-f, --fragment
-t, --template
--key
--save TEMPLATE
--extract-last # fenced code
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
llm -f github:https://github.com/banchose/skel/blob/main/awk/awk.md "can you see this little awk snippet?"
llm -t fabric:summarize -f https://...
llm -f pdf:some.pdf
### Fragments
llm fragments
llm fragments loaders         # github:
llm fragments -q pytest -q asyncio
llm fragments remove cli
llm -f fragment:
### FABRIC
llm -f fabric:expain_code
llm -f fabric:extract_wisdom
llm -f fabric:summarize
llm -f fabric:review_code
llm -f fabric:improve_writing
llm -f fabric:extract_main_idea
llm -f fabric:create_mermaid_visualization
llm -f fabric:analyze_logs
llm -f fabric:summarize_git_diff
### Test (simple eval)
llm -T simple_eval "12345 * 12345" --td  # --td tool-debug
llm prompt --help
### Append Images
cat image.jpg | llm "describe this image" -a -
cat myfile | llm "describe this image" --at - image/jpeg # --attachment-type
cat myfile | llm "describe this image" --at - image/png # --attachment-type
  --- custom functions --- 
llmbed <prompt>                   # prompt via Bedrock with date context
### jq
cat data.json | llm jq "Just the first and last names"
### AWS
aws sso login --region us-east-1 --profile test # test has bedrock
aws bedrock list-inference-profiles --region us-east-1 --profile test | grep us[.]anthropic 
### IMPORTANT
===> llm_set_bedrock_model        # set llm default model to AWS_BEDROCK_DEFAULT_MODEL
===> llm_set_openrouter_key       # load OPENROUTER_API_KEY into llm keys
===> llm_set_anthropic_key        # load ANTHROPIC_API_KEY into llm keys
===> llm_set_exa_key              # load EXA_API_KEY into llm keys

### TEMPLATES
#### CREATE SYMLINKS to git repo templates
#### cd ~/.config/io.datasette.llm/templates/ && for i in ~/gitdir/skel/llm/TEMPLATES/*;do echo "${i}";ln -s "${i}";done
llm --system 'Summarize this' --model brs --save summarize
curl -s https://example.com/ | llm -t summarize

### SCHEMA
llm --schema 'name, age int, one_sentence_bio' 'invent a cool dog'
llm --schema-multi 'name, age int, one_sentence_bio' 'invent 3 really cool dogs'
llm logs --schema-multi 'name, age int, one_sentence_bio' --data
llm logs --schema-multi 'name, ten_word_bio' --data-key items
llm logs --schema-multi 'name, ten_word_bio' --data-key items --data-array
llm logs --schema-multi 'name, ten_word_bio' --data-key items --data-ids

### TEST/TROUBLEHSOOT

llm_test_bedrock                  # run diagnostics + test prompt via Bedrock
llm_status                        # Orienting what model and what keys are set 
nvim ~/gitdir/skel/bash/bashrc_zen.d/llm-cli.sh     # llmedit alias


### llm-docs

llm install llm-docs
llm -f docs: "question"
llm -f docs:sqlite-utils "question"

### Odd Ball

# it will inspect the table for schema so no doc needed
llm chat -t brh -T 'SQLite("/home/una/temp/OPENBKDIR/webui.db")'
---------------

**The model name (-m,--model) drives the keys used**

llm -> ~/.config/io.datasette.llm/extra-openai-models.yaml 
  model_id: brs
  api_base: "http://localhost:4000" #litellm
litellm 
  litellm.conf
    profile or api_key

## Common issues

"Error: Error code: 400 - {'error': {'message': 'No connected db.', 'type': 'no_db_connection', 'param': None, 'code': '400'}}"
echo $LITELLM_MASTER_KEY
look in ~/.config/io.datasette.llm/extra-openai-models.yaml
It is set somewhere

  ## Fragments (not rag just one copy multi use)

command llm -f setup.py "extract metadata"
command llm fragments
### alias
command llm fragments set mydocs ./docs.md
command llm -f mydocs "How do I access metadata?"
command llm fragments --aliases
### github
command llm -f github:simonw/s3-credenttials

### embedding documents
llm install llm-tools-rag
llm embed-models
llm embed-models default mpnet
llm collections list
# Create a tinfoil collection example
llme_test_embed() {
  # you embed a collection and you  can use it again works well
  (
    local docdir=~/temp/tinfoil-docs

    cd "${docdir}" # && llm collections delete tinfoil

    # llm embed-multi tinfoil -m mini-l12 --files ./ '*.md' --store
    llm embed-multi tinfoil -m mpnet --files ./ '*.md' --store
  )
}

## Model aliases
llm aliases
#
## Picture
#
cat image.jpg | llm "describe this image" -a -
llm "extract text" -a image1.jpg -a image2.jpg
llm "describe this image" -a https://static.simonwillison.net/static/2024/pelicans.jpg
cat myfile | llm "describe this image" --at - image/jpeg
###########
# PIPEING
###########
cat image.jpg | llm "describe this image" -a -
cat myfile | llm "describe this image" --at - image/jpeg
git diff | llm -s 'Describe these changes'
cat llm/utils.py | llm -t pytest
####
####
name:
model:
system:
options:
  temperature: 1.8
functions: |
  def reverse_string(s: str):
      return s[::-1]

  def greet(name: str):
      return f"Hello, {name}!"
fragments:
- https://example.com/robots.txt
- /path/to/file.txt
- 993fd38d898d2b59fd2d16c811da5bdac658faa34f0f4d411edde7c17ebb0680
system_fragments:
- https://example.com/systm-prompt.txt
tools:
- llm_version
- llm_time
- simple_eval
- web_search
schema_object:
### TEMPLATE VARIABLES
llm -t recipe -p ingredients 'sausages, milk' -p country Germany # $country in the template
## IMAGE worked
wl-paste | llm -t tin "can you see this"  --at - image/jpeg
### find a conversation:
llm logs -q "keyword" | grep conversation:    # get candidate IDs
llm logs --cid <ID> | head -5                  # peek at each one
llm chat --cid <ID>                            # resume the right one
EOF
}
