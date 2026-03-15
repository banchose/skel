# Tinfoil.sh

## llm cli

### Set the api key

```sh
# set the tinfoil key
llm keys set tinfoil --value "${TINFOIL_API_KEY}"
```

## Start the tinfoil.sh proxy

- Install tinfoil.sh with `curl` install from github

```sh
tinfoil proxy   -r tinfoilsh/confidential-model-router   -e inference.tinfoil.sh   -p 8080
```

### Modify ~/.config/io.datasette.io/extra-openai-models.yaml

```yaml
- model_id: tinfoil-deepseek-r1
  model_name: deepseek-r1-0528
  api_base: "http://127.0.0.1:8080/v1"
  api_key_name: tinfoil
  supports_tools: true

- model_id: tinfoil-kimi-k2-5
  model_name: kimi-k2-5
  api_base: "http://127.0.0.1:8080/v1"
  api_key_name: tinfoil
  supports_tools: true

- model_id: tinfoil-gpt-oss-120b
  model_name: gpt-oss-120b
  api_base: "http://127.0.0.1:8080/v1"
  api_key_name: tinfoil
  supports_tools: true

- model_id: tinfoil-llama3-3-70b
  model_name: llama3-3-70b
  api_base: "http://127.0.0.1:8080/v1"
  api_key_name: tinfoil
  supports_tools: true
```
