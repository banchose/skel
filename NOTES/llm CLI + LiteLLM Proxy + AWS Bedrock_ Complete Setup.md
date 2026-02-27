# llm CLI + LiteLLM Proxy + AWS Bedrock

Route `llm` CLI through a local LiteLLM proxy to access AWS Bedrock models  
with full tool support and access to latest models.

## Architecture

```
llm CLI → (OpenAI API) → localhost:4000 → LiteLLM proxy → AWS Bedrock
```

`llm` has no knowledge of Bedrock — it just sees an OpenAI-compatible endpoint.  
LiteLLM handles auth (via boto3) and API translation.

---

## Prerequisites

### Install LiteLLM (standalone, via pipx)

```bash
pipx install 'litellm[proxy]'
# or upgrade:
pipx upgrade litellm
```

### Install boto3 into the LiteLLM pipx environment

```bash
pipx inject litellm boto3
```

### If llm is also installed via pipx and needs litellm as a library

```bash
pipx inject llm 'litellm[proxy]' --pip-args="--upgrade"
```

> LiteLLM version confirmed working: **1.81.15**

---

## AWS SSO Login

If not already authenticated (headless / no browser):

```bash
aws sso login --no-browser --use-device-code --profile test
```

Verify the session is active:

```bash
aws sts get-caller-identity --profile test
```

---

## Step 1: LiteLLM Config

File: `~/gitdir/skel/llm/litellm/litellm.conf`

```yaml
model_list:
  - model_name: bedrock-sonnet
    litellm_params:
      model: bedrock/us.anthropic.claude-sonnet-4-6
      aws_region_name: us-east-1
      aws_profile_name: test
```

### Key Points

- `model_name` is what the proxy exposes — must match `model_name` in `extra-openai-models.yaml`
- `us.anthropic.claude-sonnet-4-6` is the cross-region inference profile ID (not the bare model ID)
- Newer Anthropic models use `INFERENCE_PROFILE` type and require the `us.` prefix

### Verify inference profile ID

```bash
aws bedrock list-inference-profiles \
  --region us-east-1 \
  --profile test \
  | grep -i sonnet-4-6
```

---

## Step 2: llm extra-openai-models.yaml

File: `~/.config/io.datasette.llm/extra-openai-models.yaml`

```yaml
- model_id: brs
  model_name: bedrock-sonnet
  api_base: "http://localhost:4000"
  aliases: ["bedrock-proxy"]
  supports_tools: true
```

### Key Points

- `model_id` = what you type in `llm -m <id>`
- `model_name` = what gets sent to the LiteLLM proxy — **must match** `model_name` **in litellm.conf**
- `api_base` points to the running LiteLLM proxy
- `supports_tools: true` is **required** — without it `llm` refuses to pass `-T` tools to this model
- The name `bedrock-sonnet` is already taken by the native `llm-bedrock-anthropic` plugin,  
  so use a distinct `model_id` like `brs`

Find the config directory:

```bash
dirname "$(llm logs path)"
```

---

## Step 3: Start the Proxy

```bash
litellm --config ~/gitdir/skel/llm/litellm/litellm.conf --port 4000
```

Run in a dedicated tmux pane. The proxy must be running before using `llm -m brs`.

---

## Step 4: Test

### Test LiteLLM directly (curl)

```bash
curl -s http://localhost:4000/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "bedrock-sonnet",
    "messages": [{"role": "user", "content": "say hi"}]
  }' | python3 -m json.tool
```

### Test via llm

```bash
llm -m brs "test"
```

### Test tool support

```bash
llm -m brs -T llm_time "what time is it?"
```

---

## Troubleshooting

| Error                                                      | Cause                                                                           | Fix                                                               |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| `brs does not support tools`                               | `supports_tools: true` missing from `extra-openai-models.yaml`                  | Add `supports_tools: true` to the entry                           |
| `ResourceNotFoundException: Access denied... Legacy model` | Native `BedrockClaude` plugin alias conflict — `llm` never hit the proxy        | Use a `model_id` not claimed by the native plugin (e.g. `brs`)    |
| `Invalid model name passed in model=brs`                   | `model_name` in `extra-openai-models.yaml` doesn't match LiteLLM's `model_name` | Set `model_name: bedrock-sonnet` to match `litellm.conf`          |
| Auth failures                                              | SSO session expired                                                             | Run `aws sso login --no-browser --use-device-code --profile test` |

---

## Automated Setup Script

One-shot script that handles auth, writes both config files, and starts the proxy.

```bash
#!/usr/bin/env bash
set -euo pipefail

# ── Constants ────────────────────────────────────────────────────────────────
readonly AWS_PROFILE="test"
readonly AWS_REGION="us-east-1"
readonly LITELLM_PORT=4000
readonly LITELLM_CONF="${HOME}/gitdir/skel/llm/litellm/litellm.conf"

# ── Functions ────────────────────────────────────────────────────────────────
die() { printf '%s\n' "$*" >&2; exit 1; }

ensure_aws_session() {
    printf 'Checking AWS session...\n'
    if ! aws sts get-caller-identity \
            --region "${AWS_REGION}" \
            --profile "${AWS_PROFILE}" &>/dev/null; then
        printf 'No active session. Initiating SSO login...\n'
        aws sso login --no-browser --use-device-code --profile "${AWS_PROFILE}" \
            || die "SSO login failed"
    fi
    aws sts get-caller-identity \
        --region "${AWS_REGION}" \
        --profile "${AWS_PROFILE}" \
        || die "Unable to verify AWS identity"
}

write_litellm_config() {
    mkdir -p "$(dirname "${LITELLM_CONF}")"
    cat > "${LITELLM_CONF}" << EOF
model_list:
  - model_name: bedrock-sonnet
    litellm_params:
      model: bedrock/us.anthropic.claude-sonnet-4-6
      aws_region_name: ${AWS_REGION}
      aws_profile_name: ${AWS_PROFILE}
EOF
    printf 'LiteLLM config written to %s\n' "${LITELLM_CONF}"
}

write_extra_models() {
    local llm_config_dir extra_models
    command -v llm >/dev/null 2>&1 || die "'llm' not found in PATH"

    llm_config_dir="$(dirname "$(llm logs path)")"
    extra_models="${llm_config_dir}/extra-openai-models.yaml"

    cat > "${extra_models}" << EOF
- model_id: brs
  model_name: bedrock-sonnet
  api_base: "http://localhost:${LITELLM_PORT}"
  aliases: ["bedrock-proxy"]
  supports_tools: true
EOF
    printf 'extra-openai-models.yaml written to %s\n' "${extra_models}"
}

start_proxy() {
    command -v litellm >/dev/null 2>&1 || die "'litellm' not found in PATH"
    printf 'Starting LiteLLM proxy on port %d...\n' "${LITELLM_PORT}"
    printf 'Run this in a dedicated tmux pane, or press Ctrl-C to skip and start manually.\n'
    litellm --config "${LITELLM_CONF}" --port "${LITELLM_PORT}"
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    ensure_aws_session
    write_litellm_config
    write_extra_models
    start_proxy
}

main "$@"
```

---

## Notes

- Auth is handled entirely by LiteLLM/boto3 using `aws_profile_name: test`
- Tools (`-T`) work because `llm` uses the standard OpenAI tool interface through the proxy
- LiteLLM translates tool calls to Bedrock's Converse API
- The native `BedrockClaude` plugin models are separate and unaffected
- Confirmed working: `llm -m brs -T llm_time "what time is it?"` ✅

