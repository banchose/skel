# Readme - py1

## Note PATH

```sh
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"
```

## Bedrock

### llm

```sh
export AWS_BEARER_TOKEN_BEDROCK="DUMMY-ABSKQmVkcm9ja0FQSUtleS1oejUxLWF0LTQwNTM231MDAwNDQ4Mzp2OS9rWW5MM0RuTHlHdjkxc21SblR0K2UyV29IQys0L0s2eUwyTkFKdTBVOFpHMnl0a2lKSmZEZnVNZz0="

llm -m bedrock-claude-v4.5-sonnet -o bedrock_model_id us.anthropic.claude-sonnet-4-5-20250929-v1:0 "This is a test. Respond with 'OK'"
```

## 1. Replace API keys in Env

llm keys set anthropic --value $ANTHROPIC_API_KEY

## 2. List models

- Listing models works WITHOUT keys

```sh
llm models
```

## 3. Set the llm exa key

```sh
llm keys set exa --value $EXA_API_KEY
```

## 4. Bedrock

### Works with Bedrock Api key

```sh
llm -m bedrock-claude-v4.5-sonnet -o bedrock_model_id us.anthropic.claude-sonnet-4-5-20250929-v1:0 "This is a test. Respond with 'OK'"
```

https://github.com/simonw/llm

### With AWS SSO Login

```sh
llm -m bedrock-claude-haiku -o bedrock_model_id anthropic.claude-3-sonnet-20240229-v1:0 "This is a test. Respond with 'OK'"
```

## Anthropic

```sh
llm -m claude-4-sonnet -T web_search "search the web to get today's weather in nyc"
llm -m claude-4-sonnet -T get_answer "What is the capital of France?"
llm -m claude-4-sonnet -T get_contents "What's on the homepage of nytimes.com?"
```

## BEDROCK (WORKS!)

- MIND - MODIFY '$AWS_BEARER_TOKEN_BEDROCK' first

```sh
export AWS_BEARER_TOKEN_BEDROCK=DUMMY-ABSKQmVkcm9ja0FQSUtleS1oejUxLWF0LTQwNTM231MDAwNDQ4Mzp2OS9rWW5MM0RuTHlHdjkxc21SblR0K2UyV29IQys0L0s2eUwyTkFKdTBVOFpHMnl0a2lKSmZEZnVNZz0=
llm -m us.anthropic.claude-sonnet-4-5-20250929-v1:0  "Test, respond with 'ok'"
```

## Aider

```sh
aider --list-models bedrock/

### THIS####
export AWS_BEARER_TOKEN_BEDROCK=DUMMY-ABSKQmVkcm9ja0FQSUtleS1oejUxLWF0LTQwNTM231MDAwNDQ4Mzp2OS9rWW5MM0RuTHlHdjkxc21SblR0K2UyV29IQys0L0s2eUwyTkFKdTBVOFpHMnl0a2lKSmZEZnVNZz0=
############
aider --model bedrock/us.anthropic.claude-sonnet-4-5-20250929-v1:0
# Should be set in .bashrc
aider --model "$BEDROCK_MODEL"


# aider --model  us.anthropic.claude-3-7-sonnet-20240620-v1:0
# aider --model sonnet --api-key anthropic="${ANTHROPIC_API_KEY}"
```

## docker

```sh
cd ~/gitdir/skel/docker/builds/py1
docker build -t py1 .
```

## py1 alias

```sh
alias py1='docker run -it --rm --name py1 --hostname py1 -v ~/temp:/home/loon/temp py1:latest'
alias py1r='docker run -u root -it --rm --name py1 --hostname py1 -v ~/temp:/home/loon/temp py1:latest'
alias py1b='docker build -t py1 --build-arg USER_UID="$(id -u)" --build-arg USER_GID="$(id -g)" -t py1:latest .'
```

## loon uid (permission denied)

If you cannot write to ~/temp (mapped to host), check the uid defined in the Docker file. It will probably be different than the one the container is using
