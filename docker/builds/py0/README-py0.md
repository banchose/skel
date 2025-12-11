# Readme - py0

```
## 1. Past in ~/.bashrc_zen.d/api_keys_envs.sh

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
llm -m bedrock-claude-v4.5-sonnet -o bedrock_model_id us.anthropic.claude-sonnet-4-5-20250929-v1:0 "Remind me how to post a new version to PyPI"# Publishing to PyPI
```


### With AWS SSO Login
```sh
llm -m bedrock-claude-haiku -o bedrock_model_id anthropic.claude-3-sonnet-20240229-v1:0 "Remind me how to post a new version to PyPI"
# Anthropic
llm -m claude-4-sonnet -T web_search "search the web to get today's weather in nyc"
llm -m claude-4-sonnet -T get_answer "What is the capital of France?"
llm -m claude-4-sonnet -T get_contents "What's on the homepage of nytimes.com?"
```



# aws? worked strangely
llm -m us.anthropic.claude-sonnet-4-5-20250929-v1:0  "Test, respond with 'ok'"
```

## Aider

```sh
aider --list-models bedrock/

aider --model  us.anthropic.claude-3-7-sonnet-20240620-v1:0
aider --model sonnet --api-key anthropic="${ANTHROPIC_API_KEY}"
```

## docker

```sh
cd ~/gitdir/skel/docker/builds/py0
docker build -t py0 .
```

## py0 alias

```sh
alias py0='docker run -it --rm --name py0 --hostname py0 -v ~/temp:/home/loon/temp py0:latest'
alias py0r='docker run -u root -it --rm --name py0 --hostname py0 -v ~/temp:/home/loon/temp py0:latest'
alias py0b='docker build -t py0 --build-arg USER_UID="$(id -u)" --build-arg USER_GID="$(id -g)" -t py0:latest .'
```

## loon uid (permission denied)

If you cannot write to ~/temp (mapped to host), check the uid defined in the Docker file. It will probably be different than the one the container is using
