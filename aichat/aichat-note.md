# aichat — All-in-One LLM CLI Tool Reference

**Date:** 2026-03-17 (updated)  
**Type:** Reference  
**Scope:** CLI tool for LLM interaction — sigoden/aichat

* * *

## Summary

`aichat` is a Rust-based, all-in-one LLM CLI tool with 20+ providers built-in, requiring no plugins. It covers CMD mode, REPL mode, shell assistant, RAG, function calling, AI agents, MCP, and a built-in HTTP server. Arguably the most feature-complete LLM CLI available as of early 2026. Companion repo `llm-functions` provides a tool/agent authoring SDK in bash/JS/Python.

## Project Status

*   **Repo:** [https://github.com/sigoden/aichat](https://github.com/sigoden/aichat)
*   **Stars:** 9.2k (as of 2026-03)
*   **Latest release:** v0.30.0 (~8 months old)
*   **models.yaml:** Updated independently of releases (last update ~3 weeks ago as of 2026-03-17)
*   **License:** MIT / Apache 2.0

## Installation

```
cargo install aichat
brew install aichat        # macOS/Linuxbrew
pacman -S aichat           # Arch
scoop install aichat       # Windows
pkg install aichat         # Android Termux
```

Pre-built binaries available on GitHub Releases for macOS, Linux, Windows.

## Configuration & API Keys

### Config file location

Default: `~/.config/aichat/config.yaml` (see `aichat --info` for exact path)

**Best practice:** Relocate out of `~/.config` — that path is meant for lightweight settings, not growing data (RAG embeddings, sessions, messages). Set in your shell profile:

```bash
export AICHAT_CONFIG_DIR="$HOME/data/aichat"
```

This moves **everything** — config, rags, sessions, roles, messages — under `~/data/aichat/`. Individual overrides available but unnecessary if using default subdirectory names:

```bash
export AICHAT_RAGS_DIR="$AICHAT_CONFIG_DIR/rags"         # only if non-default
export AICHAT_SESSIONS_DIR="$AICHAT_CONFIG_DIR/sessions"  # only if non-default
export AICHAT_MESSAGES_FILE="$AICHAT_CONFIG_DIR/messages.md"
```

Resulting layout:

```
~/data/aichat/
├── config.yaml
├── .env                  # API keys
├── rags/
│   ├── pure-bash-bible.yaml
│   └── ...
├── sessions/
├── roles/
└── messages.md
```

### Minimal Claude config

```yaml
model: claude:claude-sonnet-4-6
clients:
  - type: claude
```

### Multi-client config (Claude + Ollama for embeddings)

```yaml
model: claude:claude-sonnet-4-6

clients:
  - type: claude
  - type: openai-compatible
    name: ollama
    api_base: http://localhost:11434/v1
    models:
      - name: nomic-embed-text
        type: embedding
        default_chunk_size: 1000
        max_batch_size: 50

rag_embedding_model: ollama:nomic-embed-text
```

**⚠️ Critical:** Ollama is configured as `type: openai-compatible` with `name: ollama` — there is **no** native `type: ollama` client. The `name:` field becomes the prefix in model references (e.g., `ollama:nomic-embed-text`). This is documented in the [config.example.yaml](https://github.com/sigoden/aichat/blob/main/config.example.yaml).

### Adding multiple providers

Each `clients:` entry auto-discovers all available models for that provider. A single `- type: claude` gives access to Sonnet, Haiku, Opus, etc. No need for separate entries per model.

Switch models via:

```bash
aichat --model claude:claude-haiku-3-5-20241022 "prompt"   # CLI
aichat --list-models                                         # see all available
```

In REPL: `.model` for interactive model selection.

### API Key Setup

**⚠️ Gotcha:** `aichat` uses `{client}_API_KEY` env vars where `{client}` matches the `type` field in config — **not** the provider's own convention.

| Provider | aichat expects | Common convention |
| --- | --- | --- |
| Anthropic/Claude | `CLAUDE_API_KEY` | `ANTHROPIC_API_KEY` |
| OpenAI | `OPENAI_API_KEY` | `OPENAI_API_KEY` (same) |
| Gemini | `GEMINI_API_KEY` | `GEMINI_API_KEY` (same) |

**Fix:** alias in your shell profile:

```bash
export CLAUDE_API_KEY=$ANTHROPIC_API_KEY
```

Or use `~/.config/aichat/.env` (or `$AICHAT_CONFIG_DIR/.env`):

```
CLAUDE_API_KEY=sk-ant-your-actual-key
```

**If** `api_key` **is set in** `config.yaml`**, it overrides the env var.** A stale key in the config will silently break things even if the env var is correct. Remove the `api_key` line from the client config to use env vars.

### Diagnostic

```bash
aichat --info              # shows config path, model, all settings
```

## CLI Quick Reference

```bash
aichat                                          # Enter REPL
aichat "prompt"                                 # One-shot CMD mode
aichat -m claude:claude-sonnet-4-6 "prompt"     # Specify model
aichat -r myrole "prompt"                       # Use a role
aichat -s                                       # Start temp session
aichat -s mysession                             # Named session
aichat -a myagent                               # Start agent
aichat -e "install nvim"                        # Shell assistant (execute)
aichat -c "fibonacci in js"                     # Code-only output
aichat -f file.txt -f image.png "explain"       # File inputs
aichat -f dir/ summarize                        # Directory input
aichat -f https://example.com summarize         # URL input
cat data.toml | aichat -c "to json" > out.json  # Pipe in/out
aichat --serve                                  # Start HTTP server
aichat --serve 0.0.0.0:8080                     # Server with custom addr
aichat --sync-models                            # Pull latest model list
aichat --list-models                            # Show available models
aichat --list-roles                             # Show all roles
aichat --list-sessions                          # Show all sessions
aichat --list-agents                            # Show all agents
aichat --info                                   # System/config info
aichat -r myrole --info                         # Role info
aichat -s mysession --info                      # Session info
aichat --dry-run "prompt"                       # Show message without sending
```

### Shell Integration

`alt+e` in terminal triggers aichat completions. Shell integration scripts available for bash, zsh, fish, PowerShell, nushell at `scripts/shell-integration/` in the repo.

Shell autocompletion scripts also available at `scripts/completions/`.

## Core Features

### Modes

*   **CMD mode:** One-shot from command line — `aichat hello`
*   **REPL mode:** Interactive chat with tab completion, multi-line input, history search, configurable keybindings, custom prompts

### REPL Commands

**All REPL commands start with `.` (dot).** Without the dot prefix, input is sent to the LLM as a chat message. This is the single most common mistake when starting out.

### Shell Assistant

Describe tasks in natural language → precise shell commands, OS/shell-aware. Distinct from generic prompting — purpose-built feature.

```bash
aichat -e "find all files larger than 100MB modified in the last week"
```

### Multi-Form Input

| Input | CMD | REPL |
| --- | --- | --- |
| Prompt | `aichat hello` | direct |
| Stdin | `cat data.txt | aichat` | — |
| Local files | `aichat -f image.png -f data.txt` | `.file image.png data.txt` |
| Directories | `aichat -f dir/` | `.file dir/` |
| URLs | `aichat -f https://example.com` | `.file https://example.com` |
| External commands | `` aichat -f `git diff` `` | `.file git diff` |
| Combined | `aichat -f dir/ -f data.txt explain` | `.file dir/ data.txt -- explain` |
| Last reply | — | `.file %%` |

### Sessions

Context-aware conversations with continuity. Auto-compress when token count hits threshold (default 4000).

```bash
aichat -s                    # temp session
aichat -s myproject          # named session
aichat --empty-session       # force fresh
aichat --save-session        # persist conversation
```

### Macros

Chain REPL commands into reusable sequences for repetitive workflows. Stored in `~/.config/aichat/macros/` (or `$AICHAT_CONFIG_DIR/macros/`).

## Roles

Roles customize LLM behavior — equivalent to Open WebUI skills/presets but stored as **markdown files on disk** at `~/.config/aichat/roles/`. This means they're version-controllable, scriptable, and shareable.

### Role structure

A role file (e.g. `~/.config/aichat/roles/grammar-genie.md`):

```markdown
---
model: claude:claude-sonnet-4-6
temperature: 0
top_p: 0
use_tools: null
---
Your task is to take the text provided and rewrite it into a clear, grammatically correct version while preserving the original meaning.
```

Optional frontmatter fields: `model`, `temperature`, `top_p`, `use_tools`.

### Three prompt types

**System Prompt** — no `__INPUT__` placeholder. Sets context; user input sent as separate message.

```
prompt: convert my words to emoji
```

→ generates: `[{system: "convert my words to emoji"}, {user: "angry"}]`

**Embedded Prompt** — contains `__INPUT__` placeholder. User input injected directly into prompt text. Ideal for transform-style one-liners.

```
prompt: convert __INPUT__ to emoji
```

→ generates: `[{user: "convert angry to emoji"}]`

**Few-shot Prompt** — system prompt + example pairs using `### INPUT:` / `### OUTPUT:` markers. Framework translates these into proper user/assistant message pairs.

````
prompt: |-
  Provide only code without comments or explanations.
  ### INPUT:
  async sleep in js
  ### OUTPUT:
  ```javascript
  async function timeout(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
  ```
````

→ generates: `[{system: "Provide only code..."}, {user: "async sleep in js"}, {assistant: "```javascript..."}, {user: <your input>}]`

### Tool-only roles

A role with no prompt, just tool access:

```yaml
---
use_tools: web_search,execute_command
---
```

### Built-in roles

*   `%shell%` — generates shell commands (used by `aichat -e`)
*   `%explain-shell%` — explains shell commands (used by `aichat -e` → `explain`)
*   `%code%` — generates code (used by `aichat -c`)
*   `%functions%` — attaches all tool declarations (`use_tools: all`)

Built-in role names wrapped in `%...%`. Override by creating a role with the same name.

### Comparison to Open WebUI Skills

|  | Open WebUI | aichat Roles |
| --- | --- | --- |
| System prompt | ✓ | ✓ (system prompt type) |
| Template/transform | Not native | ✓ (embedded prompt with `__INPUT__`) |
| Few-shot examples | Manual in prompt | Formalized `### INPUT:`/`### OUTPUT:` |
| Model selection | ✓ | ✓ (`model` field) |
| Temperature/params | ✓ | ✓ (`temperature`, `top_p`) |
| Tool attachment | Per-chat toggle | ✓ (`use_tools` field) |
| Storage | Web UI / database | Markdown files on disk |
| Version control | Export/import | Git — it's just files |
| Scriptable | No | `aichat -r myrole < input.txt > output.txt` |

## Function Calling, Tools & Agents (llm-functions)

### Overview

`llm-functions` ([https://github.com/sigoden/llm-functions](https://github.com/sigoden/llm-functions), 719 stars) is the companion tool/agent SDK. Write tools in bash, JS, or Python — the framework **auto-generates JSON function declarations from code comments**. No hand-written JSON schema.

### Prerequisites

*   [argc](https://github.com/sigoden/argc): bash command-line framework
*   [jq](https://github.com/jqlang/jq): JSON processor

### Setup

```bash
git clone https://github.com/sigoden/llm-functions
cd llm-functions

# Edit tools.txt — one tool filename per line
# Edit agents.txt — one agent name per line

argc build                    # generates bin/ and functions.json
argc check                    # verify env vars, dependencies, mcp-bridge

# Link to aichat
argc link-to-aichat
# OR
export AICHAT_FUNCTIONS_DIR="$(pwd)"
```

### Writing tools

Tools are functions with structured comments. The framework generates JSON declarations automatically.

**Bash:**

```bash
#!/usr/bin/env bash
set -e
# @describe Execute the shell command.
# @option --command! The command to execute.
main() {
    eval "$argc_command" >> "$LLM_OUTPUT"
}
eval "$(argc --argc-eval "$0" "$@")"
```

**Python:**

```python
def run(code: str):
    """Execute the python code.
    Args:
        code: Python code to execute, such as `print("hello world")`
    """
    exec(code)
```

**JavaScript:**

```javascript
/**
 * Execute the javascript code in node.js.
 * @typedef {Object} Args
 * @property {string} code - Javascript code to execute
 * @param {Args} args
 */
exports.run = function ({ code }) {
  eval(code);
}
```

### Writing agents

Agent = Instructions (prompt) + Tools (function calling) + Documents (RAG)

Folder structure:

```
agents/myagent/
├── index.yaml          # name, description, instructions, variables, documents
├── functions.json      # auto-generated
├── tools.txt           # shared tools to include
└── tools.{sh,js,py}    # agent-specific tools
```

`index.yaml`:

```yaml
name: MyAgent
description: This is my agent
version: 0.1.0
instructions: You are an agent that...
conversation_starters:
  - What can you do?
variables:
  - name: foo
    description: This is a foo
documents:
  - local-file.txt
  - local-dir/
  - https://example.com/remote-file.txt
```

Usage:

```bash
aichat --role %functions% what is the weather in Paris?
aichat --agent myagent "list all my todos"
```

### MCP Support (bidirectional)

*   **MCP server:** Expose `llm-functions` tools to any MCP-compatible client (not just aichat)
*   **MCP bridge:** Consume external MCP tools from other servers within aichat

### Comparison to Open WebUI tools

|  | Open WebUI | aichat + llm-functions |
| --- | --- | --- |
| Tool language | Python (decorators) | Bash, JS, or Python (comments) |
| Schema generation | Manual / decorator-based | Auto from comments/docstrings |
| Agent model | Modelfiles / presets | Folder: yaml + tools + docs |
| MCP | Yes | Yes (both server and bridge) |
| Distribution | UI import/export | Git — files on disk |

## Providers (20+)

OpenAI, Claude, Gemini, Ollama, Groq, Azure-OpenAI, VertexAI, Bedrock, GitHub Models, Mistral, Deepseek, AI21, XAI Grok, Cohere, Perplexity, Cloudflare, OpenRouter, Ernie, Qianwen, Moonshot, ZhipuAI, MiniMax, Deepinfra, VoyageAI, any OpenAI-compatible endpoint.

All built-in. No plugin installation required.

**Note on Ollama:** Despite appearing in the provider list, Ollama is configured as `type: openai-compatible` with `name: ollama` and `api_base: http://localhost:11434/v1`. There is no native `type: ollama` client type.

## Built-in HTTP Server

```
$ aichat --serve
Chat Completions API: http://127.0.0.1:8000/v1/chat/completions
Embeddings API:       http://127.0.0.1:8000/v1/embeddings
Rerank API:           http://127.0.0.1:8000/v1/rerank
LLM Playground:       http://127.0.0.1:8000/playground
LLM Arena:            http://127.0.0.1:8000/arena?num=2
```

Proxy any supported provider through a single OpenAI-compatible endpoint. Includes web playground and LLM arena for side-by-side comparison.

## RAG (Retrieval-Augmented Generation)

### Overview

Built-in document integration for context-augmented responses. No external tooling required. Requires an **embedding model** — Anthropic/Claude does not provide one, so you need a second provider (Ollama local or OpenAI API).

### Embedding Model Setup

**Anthropic has no embedding models.** Use Ollama locally or OpenAI via API.

**Recommended for small English technical corpora** (manuals, references, docs): `nomic-embed-text`
- 137M parameters, ~274MB, fast inference, light on VRAM
- 8192 token context window — handles long markdown sections
- 58.3M pulls on Ollama — most battle-tested embedding model in the ecosystem

For larger/more complex corpora: `mxbai-embed-large` (~670MB), higher quality but overkill for focused technical manuals.

```bash
ollama pull nomic-embed-text
```

### Ollama Embedding Models Comparison

| Model | Size | Best for |
| --- | --- | --- |
| `nomic-embed-text` | ~274MB | General purpose, large context window. The standard. |
| `all-minilm` | ~45MB | Tiny/fast, experiments |
| `mxbai-embed-large` | ~670MB | Higher precision, larger corpora |
| `snowflake-arctic-embed` | varies | Performance-focused |
| `bge-m3` | ~567M params | Multilingual support |
| `qwen3-embedding` | 0.6b–8b | Newest, multiple sizes |

### Optional Reranker

A reranker re-scores retrieved chunks to surface the most relevant ones before they hit the chat model. Saves tokens and improves answer quality.

```bash
ollama pull bge-reranker-v2-m3
```

Config with reranker:

```yaml
rag_embedding_model: ollama:nomic-embed-text
rag_reranker_model: ollama:bge-reranker-v2-m3
```

### Config for RAG

In `config.yaml`:

```yaml
clients:
  - type: claude
  - type: openai-compatible
    name: ollama
    api_base: http://localhost:11434/v1
    models:
      - name: nomic-embed-text
        type: embedding
        default_chunk_size: 1000
        max_batch_size: 50

rag_embedding_model: ollama:nomic-embed-text
rag_chunk_size: 1000          # prevents interactive prompt on RAG creation
rag_chunk_overlap: 50         # prevents interactive prompt on RAG creation
```

### RAG Defaults

Set these in `config.yaml` to avoid interactive prompts during RAG creation:

- `rag_embedding_model` — which model to vectorize with
- `rag_chunk_size` — size of text chunks in characters (default: null → prompts)
- `rag_chunk_overlap` — overlap between chunks (default: null → prompts)
- `rag_top_k` — number of documents retrieved per query (default: 5)

### Creating a RAG

```
aichat
> .rag pure-bash-bible
```

This initializes the RAG, prompts for documents (glob pattern like `./**/*.{md,mdx}`), ingests and embeds them, and saves to `$AICHAT_CONFIG_DIR/rags/pure-bash-bible.yaml`.

### RAG REPL Commands

| Command | What it does |
| --- | --- |
| `.rag <name>` | Create or enter a named RAG |
| `.rag` | List existing RAGs |
| `.edit rag-docs` | Add or remove documents from current RAG |
| `.rebuild rag` | Re-index after doc changes |
| `.sources rag` | Show which docs were cited in last answer |
| `.info rag` | Show RAG metadata (doc count, chunk count, etc.) |
| `.exit rag` | Leave the RAG context |

### RAG Data Location

RAG files are stored at `$AICHAT_CONFIG_DIR/rags/` (default `~/.config/aichat/rags/`). Each RAG is a `.yaml` file containing embeddings, document references, and metadata.

**Source documents must live at a stable path.** The RAG references them — if moved or deleted, you need `.edit rag-docs` and `.rebuild rag` to re-point. Don't keep source docs in `~/temp`.

Recommended source doc layout:

```
~/reference/
├── bash/pure-bash-bible/
├── tmux/
├── systemd/
└── ...
```

## Key Commands and Discoveries

**Command:** `aichat --sync-models`  
**Context:** Installed version (v0.30.0) had stale model list — missing Claude Opus 4.6 / Sonnet 4.6  
**Why it worked:** Fetches latest `models.yaml` from GitHub main branch, writes to `$AICHAT_CONFIG_DIR/models-override.yaml`. Decouples model registry from binary release cycle.  
**Significance:** Solves the "new models ship faster than software releases" problem elegantly. No LiteLLM proxy needed just for model availability.

## Gotchas and Warnings

- **Dot prefix on REPL commands:** `.rag` creates/enters a RAG. `rag` (no dot) sends "rag" as a chat prompt to the LLM. All REPL commands require the `.` prefix.
- **No native Ollama client type:** `type: ollama` does not exist. Use `type: openai-compatible` with `name: ollama` and `api_base: http://localhost:11434/v1`.
- **`type: embedding` not `type: embeddings`:** Singular. The plural form silently fails — aichat won't register the model and reports "Unknown embedding model."
- **YAML indentation matters:** `models:` must be indented under its parent client entry. If flush with `- type:`, YAML parses it as a top-level key and the client never sees it.
- **Anthropic has no embedding models:** You cannot do RAG with only a Claude client. Need Ollama (local) or OpenAI (API) for embeddings.
- **Source doc stability:** RAG references source documents by path. If they move or are deleted, the RAG breaks. Keep source docs out of temp directories.
- **API key naming:** `CLAUDE_API_KEY` not `ANTHROPIC_API_KEY`. See API Key Setup section.

## Custom Themes

Supports dark and light themes for response text and code block highlighting.

## Comparison vs `llm` (simonw)

| Dimension | `aichat` | `llm` |
| --- | --- | --- |
| Language | Rust (single binary) | Python (pip/pipx) |
| Providers | 20+ built-in | Per-provider plugin install |
| New model availability | `--sync-models` from repo | Wait for plugin update |
| Shell Assistant | Native | Not built-in |
| REPL quality | Full-featured (completion, keybinds, history) | Basic chat mode |
| RAG | Built-in | Built-in (embeddings-focused) |
| Function calling / MCP | Native | Plugin-dependent |
| AI Agents | Built-in | Not native |
| Macros | Yes | No (templates are different) |
| HTTP server / playground | Built-in | No |
| Plugin ecosystem | None (not needed) | Rich, community-extensible |
| Python library | No (CLI only) | Yes (`import llm`) |
| SQLite queryability | Sessions stored | First-class queryable dataset (Datasette DNA) |
| Embeddings | Supported | First-class standalone workflows |

**Bottom line:** `aichat` is batteries-included; `llm` is composable/extensible. Both best-in-class, different philosophies.

## Documentation

*   Wiki: Chat-REPL Guide, Command-Line Guide, Role Guide, Macro Guide, RAG Guide
*   Wiki: Environment Variables, Configuration Guide, Custom Theme, Custom REPL Prompt, FAQ
*   All linked from repo README and GitHub wiki

## References

*   [https://github.com/sigoden/aichat](https://github.com/sigoden/aichat)
*   [https://github.com/sigoden/aichat/blob/main/config.example.yaml](https://github.com/sigoden/aichat/blob/main/config.example.yaml)
*   [https://github.com/sigoden/aichat/wiki/RAG-Guide](https://github.com/sigoden/aichat/wiki/RAG-Guide)
*   [https://github.com/sigoden/aichat/wiki/Environment-Variables](https://github.com/sigoden/aichat/wiki/Environment-Variables)
*   [https://github.com/sigoden/aichat/wiki/Role-Guide](https://github.com/sigoden/aichat/wiki/Role-Guide)
*   [https://github.com/sigoden/aichat/wiki/Command-Line-Guide](https://github.com/sigoden/aichat/wiki/Command-Line-Guide)
*   [https://github.com/sigoden/llm-functions](https://github.com/sigoden/llm-functions)
*   Related note: "CLI & TUI Tools for LLM Interaction — Landscape Overview" (ID: 9522632e-276c-4cfc-97fe-64c180ae4bb7)

* * *

## Additions

> Items added outside of a structured update. May be rough, incomplete, or shorthand.  
> These should be integrated into the note body on the next formal update.

_(none yet)_