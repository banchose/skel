# LLM CLI — OpenRouter, Exa Web Search & Troubleshooting

## Two Ways to Use Exa with LLM CLI

### Method 1: OpenRouter Server-Side (blanket augmentation)

```bash
llm -m openrouter/anthropic/claude-sonnet-4.6 -o online 1 'your prompt here'
```

*   `-o online 1` activates OpenRouter's web search plugin server-side
    
*   For Anthropic models, defaults to **native** Anthropic search; falls back to **Exa** for other providers
    
*   To force Exa: configure at openrouter.ai/settings/plugins → set engine to `exa`
    
*   Search results injected into prompt **every request**, unconditionally
    
*   Pricing (Exa via OpenRouter): $4/1,000 results (default 5 = $0.02/request) + LLM token costs
    

### Method 2: llm-tools-exa (model-controlled tool use)

```bash
# Requires separate Exa API key
llm keys set exa

# Bundle all Exa tools
llm -m claude-sonnet-4.6 -T Exa 'search the web for today's news'

# Individual tools
llm -m claude-sonnet-4.6 -T web_search 'search the web for today's weather in nyc'
llm -m claude-sonnet-4.6 -T get_answer 'What is the capital of France?'
llm -m claude-sonnet-4.6 -T get_contents "What's on the homepage of nytimes.com"
```

*   Model **decides** when and what to search (tool calling)
    
*   Works with **any** model that supports tools (Bedrock, Anthropic direct, OpenRouter, etc.)
    
*   Three tools: `web_search`, `get_answer`, `get_contents` (webpage → markdown)
    
*   `-T Exa` bundles all three
    
*   Requires its own Exa API key (separate from OpenRouter)
    
*   Plugin: github.com/daturkel/llm-tools-exa (v0.5.0)
    

### Comparison

|  | OpenRouter `-o online 1` | `llm-tools-exa` |
| --- | --- | --- |
| Search trigger | Every request, unconditionally | Model decides when |
| Engine control | Dashboard config or default | Direct Exa API |
| Works with | OpenRouter models only | Any model with tool support |
| API key | OpenRouter key | Separate Exa key |
| Granularity | Search only | Search + answer + get_contents |
| Cost | $0.02/req (5 results) via OpenRouter | Exa API pricing directly |

* * *

## Setup Summary

| Component | Status |
| --- | --- |
| `llm` CLI | v0.28, installed via pipx |
| `llm-openrouter` | v0.5 installed |
| `llm-tools-exa` | v0.5.0 installed |
| `llm-tools-simpleeval` | v0.1.1 installed |
| OpenRouter API key | Set via `llm keys set openrouter` |
| Exa API key | Set via `llm keys set exa` (needed for llm-tools-exa) |
| Default model | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` (Bedrock) |

### Alias for Convenience

```bash
llm aliases set sonnet46 openrouter/anthropic/claude-sonnet-4.6
llm -m sonnet46 -o online 1 'what happened in the news today'
```

* * *

## Key Commands

```bash
llm keys set openrouter          # Set/update OpenRouter API key
llm keys set exa                 # Set/update Exa API key
llm openrouter models            # List OpenRouter models (detailed)
llm openrouter models --free     # Free models only
llm openrouter key               # API key info, rate limits, usage
llm models | grep openrouter     # Verify exact model slugs available
```

* * *

## Troubleshooting: 401 "User not found" from OpenRouter

**Symptom:**

```
Error: Error code: 401 - {'error': {'message': 'User not found.', 'code': 401}}
```

**Cause:** The key stored by `llm` does not match the valid OpenRouter API key. Note that `llm keys set` does **not** validate the key — it accepts anything silently.

**Resolution (2026-02-24):**

1.  Verify the key works independently:
    

```bash
curl https://openrouter.ai/api/v1/models \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" | head -c 200
```

2.  If curl succeeds, sync the stored key from the env var:
    

```bash
llm keys set openrouter --value "$OPENROUTER_API_KEY"
```

3.  Verify the model slug is correct before running:
    

```bash
llm models | grep openrouter | grep -i sonnet
```

**Root cause confirmed:** `$OPENROUTER_API_KEY` env var contained a valid key but `llm keys set openrouter` had been set to a different/incorrect value.

* * *

## Other Useful OpenRouter Options (via llm-openrouter)

```bash
# Provider routing
llm -m openrouter/meta-llama/llama-3.1-8b-instruct hi \
  -o provider '{"quantizations": ["fp8"]}'

# Reasoning control
llm -m openrouter/openai/gpt-5 'prove dogs exist' -o reasoning_effort high

# Tool use with debug output
llm -m openrouter/openai/gpt-5 -T llm_version -T llm_time \
  "What version of LLM and what time is it?" --tools-debug
```

* * *

## LLM Plugin Directory — Notable Items

> **Reference**: llm.datasette.io/en/stable/plugins/directory.html  
> Snapshot reviewed 2026-02-24. Check for updates.

### Installed Tool Plugins

| Plugin | What It Does |
| --- | --- |
| `llm-tools-exa` | Exa web search, Q&A, get_contents as LLM tools |
| `llm-tools-simpleeval` | Math/expression evaluation |

### Other Notable Plugins (not yet installed)

| Plugin | What It Does |
| --- | --- |
| `llm-tools-sqlite` | Read-only SQL against local SQLite DBs |
| `llm-tools-quickjs` | Sandboxed JS interpreter as a tool |
| `llm-jq` | Pipe JSON + describe a jq program (**note:** `llm-jq` not `lm-jq`) |
| `llm-fragments-github` | Load entire GitHub repos as context |
| `llm-fragments-pdf` | PDF → markdown fragments |
| `llm-fragments-site-text` | Website → markdown fragments |
| `llm-fragments-reader` | URL through Jina Reader API |
| `llm-hacker-news` | HN threads as fragments |
| `llm-video-frames` | Video → JPEG frames for vision models |
| `llm-cmd` / `llm-cmd-comp` | Shell command generation |

* * *

## Architecture Notes

*   OpenRouter's `:online` model variant = `plugins: [{ id: "web" }]` in the API
    
*   `llm-openrouter` exposes this as `-o online 1`
    
*   `llm-tools-exa` is completely independent — talks to Exa API directly, works with any tool-capable model
    
*   Web search results from OpenRouter are returned as `annotations` in the response (`url_citation` format)
    
*   The `extra-openai-models.yaml` approach (append `:online` to model_name) also works but is unnecessary given the plugin's native `-o online 1` support
