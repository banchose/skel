# Bedrock via LiteLLM — New Machine Setup & Daily Use

## What This Is

`llm` CLI doesn't talk to AWS Bedrock directly. It talks to a local LiteLLM proxy  
(localhost:4000) that translates OpenAI API calls to Bedrock's Converse API.

```
llm -m brs "hello" → localhost:4000 → LiteLLM → AWS Bedrock
```

If you get `Error: Connection error.` from `llm -m brs`, it means the LiteLLM proxy isn't running.

* * *

## Files (all in git repo)

```
~/gitdir/skel/llm/litellm/
├── START_LOCAL_LITELLM.sh    # starts the proxy + validates prerequisites
├── SETUP_LLM_BEDROCK.sh      # one-time setup per machine (symlink + checks)
├── extra-openai-models.yaml   # llm config — defines brs/brh/bro model aliases
└── litellm.conf               # LiteLLM config — maps model names to Bedrock model IDs
```

* * *

## One-Time Setup Script: `SETUP_LLM_BEDROCK.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$HOME/gitdir/skel/llm/litellm"
EXTRA_MODELS="extra-openai-models.yaml"
LLM_CONFIG_DIR="$(dirname "$(llm logs path)")"

echo "=== Bedrock via LiteLLM: One-Time Setup ==="

# Check llm is installed
command -v llm >/dev/null 2>&1 || { echo "ERROR: llm not found. Install: pipx install llm"; exit 1; }

# Check litellm is installed
command -v litellm >/dev/null 2>&1 || { echo "ERROR: litellm not found. Install: pipx install 'litellm[proxy]'"; exit 1; }

# Check boto3 is available to litellm
python3 -c "import boto3" 2>/dev/null || { echo "ERROR: boto3 not importable. Install: pip install boto3>=1.28.57"; exit 1; }

# Symlink extra-openai-models.yaml into llm config dir
TARGET="${LLM_CONFIG_DIR}/${EXTRA_MODELS}"
if [[ -L "$TARGET" ]]; then
    echo "OK: Symlink already exists: $TARGET"
elif [[ -f "$TARGET" ]]; then
    echo "WARNING: $TARGET exists as a regular file (not a symlink)."
    echo "         Back it up and re-run, or manually replace with symlink."
    exit 1
else
    ln -s "${REPO_DIR}/${EXTRA_MODELS}" "$TARGET"
    echo "OK: Created symlink: $TARGET -> ${REPO_DIR}/${EXTRA_MODELS}"
fi

# Verify llm sees the models
echo ""
echo "=== Registered Bedrock proxy models ==="
llm models | grep -E '(brs|brh|bro)' || echo "WARNING: No bedrock proxy models found. Check ${EXTRA_MODELS}"

echo ""
echo "Setup complete. To use:"
echo "  1. aws sso login --profile test"
echo "  2. ~/gitdir/skel/llm/litellm/START_LOCAL_LITELLM.sh   (in a tmux pane)"
echo "  3. llm -m brs 'hello'"
```

* * *

## Daily Start Script: `START_LOCAL_LITELLM.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

LITELLM_CONFIG_DIR="$HOME/gitdir/skel/llm/litellm"
LITELLM_CONFIG="litellm.conf"
LITELLM_PORT=4000
AWS_PROFILE_NAME="test"

echo "=== Starting LiteLLM Bedrock Proxy ==="

# Check litellm exists
command -v litellm >/dev/null 2>&1 || {
    echo "ERROR: litellm not found."
    echo "FIX:   pipx install 'litellm[proxy]'"
    exit 1
}

# Check AWS auth is active
if ! aws sts get-caller-identity --profile "${AWS_PROFILE_NAME}" >/dev/null 2>&1; then
    echo "ERROR: AWS session not active for profile '${AWS_PROFILE_NAME}'."
    echo "FIX:   aws sso login --profile ${AWS_PROFILE_NAME}"
    exit 1
fi
echo "OK: AWS profile '${AWS_PROFILE_NAME}' authenticated."

# Check port not already in use
if ss -tlnp 2>/dev/null | grep -q ":${LITELLM_PORT} "; then
    echo "WARNING: Port ${LITELLM_PORT} already in use. LiteLLM may already be running."
    echo "         Check with: curl -s http://localhost:${LITELLM_PORT}/health"
    exit 1
fi

# Check config exists
if [[ ! -f "${LITELLM_CONFIG_DIR}/${LITELLM_CONFIG}" ]]; then
    echo "ERROR: Config not found: ${LITELLM_CONFIG_DIR}/${LITELLM_CONFIG}"
    exit 1
fi

echo "Starting proxy on port ${LITELLM_PORT}..."
echo "Stop with Ctrl+C"
echo ""

set -x
litellm -c "${LITELLM_CONFIG_DIR}/${LITELLM_CONFIG}" --port "${LITELLM_PORT}"
```

* * *

## Troubleshooting Quick Reference

| Symptom | Cause | Fix |
| --- | --- | --- |
| `Error: Connection error.` from `llm -m brs` | LiteLLM proxy not running | Start it: `START_LOCAL_LITELLM.sh` |
| `AWS session not active` from start script | SSO session expired | `aws sso login --profile test` |
| `Invalid model name passed in model=brs` | `model_name` mismatch between yaml files | `model_name` in extra-openai-models.yaml must match `model_name` in litellm.conf |
| `ResourceNotFoundException: Legacy model` | Native BedrockClaude plugin alias conflict | Use `brs`/`brh`/`bro` model IDs, not `bedrock-sonnet` |
| `Port 4000 already in use` | Proxy already running or stale process | `curl localhost:4000/health` or kill the process |

* * *

## Model Aliases

| llm alias | LiteLLM model_name | Bedrock model |
| --- | --- | --- |
| `brs` / `bedrock-sonnet-proxy` | bedrock-sonnet | `us.anthropic.claude-sonnet-4-6` |
| `brh` / `bedrock-haiku-proxy` | bedrock-haiku | (set in litellm.conf) |
| `bro` / `bedrock-opus-proxy` | bedrock-opus | (set in litellm.conf) |

* * *

## Config File Reference

### litellm.conf

```yaml
model_list:
  - model_name: bedrock-sonnet
    litellm_params:
      model: bedrock/us.anthropic.claude-sonnet-4-6
      aws_region_name: us-east-1
      aws_profile_name: test
```

### extra-openai-models.yaml

```yaml
- model_id: brs
  model_name: bedrock-sonnet
  api_base: "http://localhost:4000"
  aliases: ["bedrock-sonnet-proxy"]
```

### Key distinction

*   `model_id` → what you type in `llm -m <this>`
    
*   `model_name` → what gets sent to the LiteLLM proxy (must match litellm.conf)