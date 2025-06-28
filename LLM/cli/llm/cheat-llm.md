# llm cheat

## Set default model

```sh
llm models default openrouter/anthropic/claude-sonnet-4
```

## Help

## Pettern

```sh
llm –help

    llm prompt –help
    llm chat –help
    llm keys –help
```

```sh
llm prompt --help
# -td, tools-debug: tool debug
# -f, --fragment: fragment
# -q, --query: (0 or more -q) use first model in search,
# -s, --system: system prompt
# -a, --attachement: <path, url, ->
# -c, --continue: chat?
# -u, --usage: Show prompt usage
# -x, --extract: extract code from fenced code blocks
# -xl, --extract-last: the last one
```

## Search Web?

```sh
llm -m anthropic/claude-sonnet-4-0  -T web_search "search the web to get todays weather in nyc"

```

```sh
llm -m openrouter/anthropic/claude-sonnet-4 -o online 1 'key events on june 1st 2025'
```

## OpenRouter

```sh
llm install llm-openrouter
llm openrouter models --json
llm openrouter models --free # No $$$
# Worked!
llm -m openrouter/anthropic/claude-sonnet-4 "test, please ignore"
llm keys
# or
## llm openrouter key --key sk-xxx
```

## Fast

```sh
llm -m openrouter/anthropic/claude-2 "Five spooky names for a pet tarantula"
llm aliases set claude openrouter/anthropic/claude-sonnet-4
cat llm_openrouter.py | llm -m claude -s 'write some pytest tests for this'
```

## Fast Screen Capture

```sh
grim -g "$(slurp -d)"

```

## Options

```sh
llm models --options
```

## Model

```sh
# -q <term> - query
llm models -q gpt-4o
llm models -q 4o -q mini
```

## chat

```sh
llm chat
```

```sh
llm -m gpt-4o "ten names for a pet octopus"
```

```sh
llm "Suggest suitable names for a python function that takes a list of \
  numbers and returns a new list containing only the even numbers from \
  the original list."
```

## Template

```sh
llm --system 'You are a sentient cheesecake' -m gpt-4o --save cheesecake
llm chat -t cheesecake
```

## Continue

```sh
llm -c "more suggestions please"
```

## Pipe and prompt

```sh
cat ./somefile.py | \
  llm --system 'Describe this code succinctly'
```

## Jargon Delineater

```sh
llm -s "Explain all acronyms and jargon terms in the entered \
  text, as a markdown list. Use **bold** for the term, then \
  provide an explanation. [...]" --sav
```

```sh
curl -s https://manassaloi.com/2023/12/26/tech-power-law.html | \
  strip-tags article | \
  llm -t dejargonizer
```
