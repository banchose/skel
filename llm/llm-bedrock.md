# llm to bedrock quick

## Login to aws (--profile test)

- llm knows about aws auth and the test profile is in the extra file

```
aws sso login --region us-east-1 --profile test
# For lm cli
ln -s ~/gitdir/skel/llm/litellm/extra-openai-models.yaml ~/.config/io.datasette.llm`
# For litellm
ln -s ~/gitdir/skel/llm/litellm/litellm.conf
```

## llm: extra-openai-modes.yaml

```yaml
- model_id: brs # in llm models list
  model_name: bedrock-sonnet # passed to litellm (openai)
  api_base: "http://localhost:4000"
  aliases: ["bedrock-sonnet-proxy"]
  supports_tools: true

- model_id: brh
  model_name: bedrock-haiku
  api_base: "http://localhost:4000"
  aliases: ["bedrock-haiku-proxy"]
  supports_tools: true

- model_id: bro
  model_name: bedrock-opus
  api_base: "http://localhost:4000"
  aliases: ["bedrock-opus-proxy"]
  supports_tools: true
```

## litellm: litellm.yaml

```yaml
model_list:
  - model_name: bedrock-sonnet
    litellm_params:
      model: bedrock/us.anthropic.claude-sonnet-4-6
      aws_region_name: us-east-1
      aws_profile_name: test
  - model_name: bedrock-haiku
    litellm_params:
      model: bedrock/us.anthropic.claude-haiku-4-5-20251001-v1:0
      aws_region_name: us-east-1
      aws_profile_name: test
  - model_name: bedrock-opus
    litellm_params:
      model: bedrock/us.anthropic.claude-opus-4-6
      aws_region_name: us-east-1
      aws_profile_name: test
```
