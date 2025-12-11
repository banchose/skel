#!/usr/bin/env bash

set -xeuo pipefail

# Consider adding a trap at the top:
trap 'pkill -f litellm; pkill -f mcpo; exit' INT TERM EXIT

BACKDIRNAME=OPENBKDIR
OPENDATA=~/temp/"${BACKDIRNAME}"

# Check and install all dependencies in ONE loop
echo "Checking dependencies..."
for tool in pipx sqlite3 jq aws nc uv litellm; do
  if ! command -v "$tool" &>/dev/null; then
    echo "$tool not found..."

    case $tool in
    litellm)
      echo "Installing litellm via pipx..."
      pipx install --force 'litellm[proxy]'
      ;;
    uv)
      echo "Installing uv via pipx..."
      pipx install 'uv'
      ;;
    pipx)
      echo "Error: pipx must be installed first"
      echo "Install with: sudo apt install pipx"
      exit 1
      ;;
    *)
      echo "Error: $tool is required but not installed"
      echo "Install with your package manager (apt/yum/brew)"
      exit 1
      ;;
    esac
  fi
done

echo "This will move an existing data directory to a date named directory"
echo "############################################################################################"
echo "#"
echo "#                  Remember to change litellm to http://localhost:4000"
echo "#"
echo "############################################################################################"
echo "REMEMBER to change litellm-service to localhost in the admin panel connections for litellm (anthropic access)"
sleep 5

########################### DESTROY ######################################################
#
[[ -d "${OPENDATA}" ]] && mv "${OPENDATA}" "${OPENDATA}"-"$(date +%Y%m%d_%H%M%S)"
mkdir -p "${OPENDATA}"

# aws s3 ls --region us-east-1 --profile test
# aws s3 ls openwebui-db-backups --region us-east-1 --profile test
# aws s3 ls s3://openwebui-db-backups --recursive --human-readable --summarize --region us-east-1 --profile test
# aws s3api get-bucket-versioning --bucket openwebui-db-backups --region us-east-1 --profile test

aws s3 sync s3://openwebui-db-backups/vector_db/ "${OPENDATA}"/vector_db --region us-east-1 --profile test || {
  echo "vector copy failed"
  exit 1
}
aws s3 sync s3://openwebui-db-backups/uploads/ "${OPENDATA}"/uploads --region us-east-1 --profile test || {
  echo "uploads copy failed"
  exit 1
}
aws s3 cp s3://openwebui-db-backups/webui.db "${OPENDATA}"/webui.db --region us-east-1 --profile test || {
  echo "webui.db copy failed"
  exit 1
}

# Create the config file
cat >|"${OPENDATA}"/litellm_config.yaml <<'EOF'
model_list:
  - model_name: claude-sonnet-4
    litellm_params:
      model: bedrock/us.anthropic.claude-sonnet-4-20250514-v1:0
      aws_region_name: us-east-1
  - model_name: claude-4-5-sonnet
    litellm_params:
      model: bedrock/us.anthropic.claude-sonnet-4-5-20250929-v1:0
      aws_region_name: us-east-1
  - model_name: claude-3-5-sonnet
    litellm_params:
      model: bedrock/us.anthropic.claude-3-5-sonnet-20240620-v1:0
      aws_region_name: us-east-1
  - model_name: claude-3-haiku
    litellm_params:
      model: bedrock/us.anthropic.claude-3-haiku-20240307-v1:0
      aws_region_name: us-east-1
  - model_name: claude-3-opus
    litellm_params:
      model: bedrock/anthropic.claude-3-opus-20240229-v1:0
      aws_region_name: us-east-1
  - model_name: claude-opus-4-1
    litellm_params:
      model: bedrock/us.anthropic.claude-opus-4-1-20250805-v1:0
      aws_region_name: us-east-1
EOF
######################### DESTROY ######################################################

# Install litellm
# pipx install 'litellm[proxy]'

# Run it (uses your AWS credentials from environment/~/.aws)
pkill -f litellm || true
litellm --config "${OPENDATA}"/litellm_config.yaml --port 4000 &
echo "##############################################################################################"
echo "#"
echo "# Don't for get to change 'litellm-service' to 'localhost' in OpenWebUI Settings Connections"
echo "# You will get failed to connect on 4000 errors"
echo "#"
echo "##############################################################################################"
sleep 2
# pipx environment
# pipx install open-webui
# pipx install --python python3.12 open-webui
# pipx runpip open-webui show open-webui | grep Location

# Instead of sleep 5, wait for service readiness:
timeout 30 bash -c 'until nc -z localhost 4000; do sleep 1; done' || {
  echo "LiteLLM failed to start on port 4000"
  exit 1
}

uvx mcpo --port 8000 --api-key mcpo-secret-key-123 -- uvx mcp-server-time &
sleep 5

## mcpo front end mcp-proxy for aws knowledge-mcp - Since no --host because runninig local,  name, must change port
uvx mcpo --port 8001 --api-key aws-knowledge-key-123 -- uvx mcp-proxy --transport streamablehttp https://knowledge-mcp.global.api.aws &
sleep 5

## mcpo for aws documentation
uvx mcpo --port 8002 --api-key mcpo-docs-key-123 -- uvx awslabs.aws-documentation-mcp-server &
sleep 5

## mcpo for context7
uvx mcpo --port 8003 -- npx @upstash/context7-mcp &

sleep 5
##############################################################################################

# After restoring webui.db from S3, before starting Open WebUI:
sleep 2
echo "Updating LiteLLM connection for local environment..."
sqlite3 "${OPENDATA}/webui.db" "UPDATE config SET data = json_set(data, '$.openai.api_base_urls[2]', 'http://localhost:4000') WHERE json_extract(data, '$.openai.api_base_urls[2]') = 'http://litellm-service:4000';"
sleep 2

sqlite3 "${OPENDATA}/webui.db" <<EOF
UPDATE config SET data = json_set(
  data,
  '$.tool_server.connections[0].url', 'http://localhost:8000',
  '$.tool_server.connections[1].url', 'http://localhost:8002',
  '$.tool_server.connections[2].url', 'http://localhost:8001',
  '$.tool_server.connections[3].url', 'http://localhost:8003'
);
EOF

# Way of the one-liner
# sqlite3 "${OPENDATA}/webui.db" "UPDATE config SET data = json_set(data, '\$.tool_server.connections[0].url', 'http://localhost:8000', '\$.tool_server.connections[1].url', 'http://localhost:8002', '\$.tool_server.connections[2].url', 'http://localhost:8001', '\$.tool_server.connections[3].url', 'http://localhost:8003');"

sqlite3 "${OPENDATA}/webui.db" "SELECT json_extract(data, '$.tool_server.connections') FROM config;" | jq '.[].url'

# Run OpenWebuUI Server probably on port 8080
# alias open-webui-serve='DATA_DIR=~/temp/vector open-webui serve'
DATA_DIR="${OPENDATA}" open-webui serve
