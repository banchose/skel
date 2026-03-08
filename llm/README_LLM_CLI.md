# Configure llm and litellm for AWS Bedrock

## Example aliases

```sh
alias llm_start_litellm='litellm --config ~/gitdir/skel/llm/litellm/litellm.conf --port 4000 >/tmp/litellm-log-1772929949 2>&1 &'
alias llm_start_litellm_debug='litellm --config ~/gitdir/skel/llm/litellm/litellm.conf --port 4000 --detailed_debug'

alias orte='command llm -u -m "${OPENROUTER_DEFAULT_MODEL}" -T Exa'
alias orts='command llm -u -m "${OPENROUTER_DEFAULT_MODEL}" -o online 1'

```

## llm cli

- llm cli is driven by the model choice - it will find the provider env api key from the model name
- llm cli will find the models configurd in `extra-openai-models` putting them under OpenAI as the provider
  - `llm models list`
  - `llm defaults model`
  - `llm defaults model <model>`
- litellm is used to allows standard openai protocol (better support) for Anthropic models
- Each will point to the same local running litellm instance on port `4000` started with `llm_start_litellm`

### Configuration file
```sh

`cat ~/.config/io.datasette.llm/extra-openai-models.yaml`
```

```yaml
- model_id: brs
  model_name: bedrock-sonnet
  api_base: "http://localhost:4000"
  aliases: ["bedrock-sonnet-proxy"]
  supports_tools: true
  supports_schema: true
  vision: true
- model_id: brh
  model_name: bedrock-haiku
  api_base: "http://localhost:4000"
  aliases: ["bedrock-haiku-proxy"]
  supports_tools: true
  supports_schema: true
  vision: true
- model_id: bro
  model_name: bedrock-opus
  api_base: "http://localhost:4000"
  aliases: ["bedrock-opus-proxy"]
  supports_tools: true
  supports_schema: true
  vision: true
```

### set the default model

```sh
llm models default brs
```

## litellm

### Set the Bedrock API Key

- **Set** `${AWS_BEARER_TOKEN_BEDROCK}` (and even if signed on as aws admin) litellm will not work without the key set

### Start LiteLLM

```sh
litellm --config ~/gitdir/skel/llm/litellm/litellm.conf --port 4000  
# litellm --config ~/gitdir/skel/llm/litellm/litellm.conf --detailed_debug --port 4000  
```

###  Test LiteLLM with curl

#### LITELLm

```sh
export AWS_BEARER_TOKEN_BEDROCK=blahblahblah
pkill lilellm
litellm --config ~/gitdir/skel/llm/litellm/litellm.conf --port 4000 --detailed_debug
```

#### curl

- `bedrock-haiku` found defined in `~/.config/io.datasette.llm/extra-openai-models.yaml`
- llm -> extra-openai-models.yaml -> localhost:4000 -> export AWS_BEARER_TOKEN_BEDROCK=... --> litellm.conf --> litellm

```sh
# this worked at one time
# model is an alias in ~/.config/io.datasette.llm/extra-openai-models.yaml
curl --location "http://localhost:4000/chat/completions" --header 'Content-Type: application/json' --data '{
    "model": "bedrock-haiku",
    "messages": [
        {
        "role": "user",
        "content": "Hello, what model are you?"
        }
    ]
}'
```
