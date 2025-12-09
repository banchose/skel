# Readme - alpine0

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

## 4. Test llm with exa search

```sh
llm -m claude-4-sonnet -T web_search "search the web to get today's weather in nyc"
llm -m claude-4-sonnet -T get_answer "What is the capital of France?"
llm -m claude-4-sonnet -T get_contents "What's on the homepage of nytimes.com
```

```

```
