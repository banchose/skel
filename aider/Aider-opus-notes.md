# Aider + Neovim — Setup, Config Editing, and Usage Reference

**Date:** 2026-03-20  
**Type:** Reference + Solved Problem  
**Environment / Scope:** Aider v0.86.2, joshuavial/aider.nvim (lazy.nvim), LazyVim, Bash 5.3, Arch Linux

* * *

## Summary

Aider inside nvim kept selecting `claude-sonnet-4-5` via OpenRouter despite explicit `--model claude-sonnet-4-6` flags in the plugin keymap. Root cause was a combination of environment variable precedence and the plugin's session reattach behavior. Solved by moving model selection to `~/.aider.conf.yml` and letting the API key come from the shell environment.

## Background / Context

Multiple API keys set in bash env: `ANTHROPIC_API_KEY`, `OPENROUTER_API_KEY`. Aider works correctly from the CLI with explicit `--model` and `--api-key` flags. The goal was to get the same behavior when launching aider from nvim via the `joshuavial/aider.nvim` plugin.

## Problem or Goal

Get aider to use `claude-sonnet-4-6` via the Anthropic API when launched from the nvim plugin, instead of defaulting to `claude-sonnet-4-5` via OpenRouter.

## What Was Tried

*   **Custom keymap with** `--model` **and** `--api-key` **flags in the plugin config** — keymap registered correctly (confirmed via `:verbose nmap <leader>Ao`) but aider still showed `claude-sonnet-4-5`. The plugin reattaches to existing aider sessions even when flags change, so the old session persisted.

*   **Unsetting** `OPENROUTER_API_KEY` before launching nvim — still got `claude-sonnet-4-5` because the `--model sonnet` shorthand in aider v0.86.2 resolves to `claude-sonnet-4-5`, not `4-6`.

*   **Using** `vim.fn.setenv("OPENROUTER_API_KEY", "")` **in nvim config** — addressed the wrong provider issue but didn't fix the model alias resolution.

*   **Passing** `--model claude-sonnet-4-6` **explicitly** from the nvim command line (`:AiderOpen --model claude-sonnet-4-6`) — still routed through OpenRouter when that key was in the environment.

## Solution / Finding

**Move model config to aider's own config file.** Keep the nvim plugin config minimal.

`~/.aider.conf.yml`:

```yaml
model: claude-sonnet-4-6
```

`ANTHROPIC_API_KEY` stays in the shell environment — aider picks it up automatically.

`~/.config/nvim/lua/plugins/aider.lua` (the simple version):

```lua
return {
  "joshuavial/aider.nvim",
  opts = {
    auto_manage_context = true,
    default_bindings = true,
    debug = false,
  },
}
```

Deleted the overcomplicated `aider-nvim.lua` that tried to thread model/key through the keymap.

## Key Commands and Discoveries

*   `aider --list-models claude` — list known model aliases for verification
*   `:verbose nmap <leader>Ao` — confirm exact keymap definition and source file in nvim
*   `aider --model claude-sonnet-4-6 --api-key anthropic=$ANTHROPIC_API_KEY` — the CLI invocation that always worked; useful as a sanity check

`--model sonnet` **alias:** In aider v0.86.2, `sonnet` resolves to `claude-sonnet-4-5`. Use the full model identifier `claude-sonnet-4-6` for the current model.

`claude-sonnet-4-6` — the official Anthropic API model identifier string, released 2026-02-17. $3/$15 per 1M tokens, 1M context window (GA as of March 2026).

## Gotchas and Warnings

*   **API key precedence:** When both `OPENROUTER_API_KEY` and `ANTHROPIC_API_KEY` exist in the environment, aider may auto-select OpenRouter. The `--api-key` CLI flag can override this, but `~/.aider.conf.yml` with an explicit `anthropic-api-key` or model string is more reliable.

*   **Session reattach:** `joshuavial/aider.nvim` reattaches to an existing aider job if one is running, _ignoring any new flags_. Must `/exit` the old session before restarting with different parameters.

*   **Config load order:** `~/.aider.conf.yml` → git repo root `.aider.conf.yml` → cwd `.aider.conf.yml` → CLI args. Later overrides earlier.

*   **API keys in YAML:** Only OpenAI and Anthropic keys can go in `.aider.conf.yml`. All other provider keys must use `.env` or environment variables.

*   **Duplicate plugin specs in LazyVim:** Having two files defining the same plugin (`aider.lua` and `aider-nvim.lua`) causes unpredictable loading. Keep one.

* * *

## Preventing Auto-Commits

Aider auto-commits changes by default. To disable:

**CLI flag:** `--no-auto-commits`

**In `~/.aider.conf.yml`:**

```yaml
auto-commits: false
```

With auto-commits off, aider still makes the edits to files but does **not** `git add` or `git commit`. You review and commit yourself. The `/diff` command shows what changed since the last message. `/undo` reverts the last aider-made commit (only relevant if auto-commits are on).

**Dry run / plan first approach:** Use `/ask` to discuss a plan without any file edits. When satisfied, say "go ahead" (without `/ask`). This is the "planning mode" equivalent.

* * *

## Controlling the Repo Scan and Data Flow

**The issue:** On launch, aider automatically scans the git repo and builds a repo map (file names, function/class signatures, structural relationships). This is sent to the model provider as context — before you type anything. Even without file contents, this leaks project architecture, naming, dependencies, and internal structure to a third-party API. For client work or anything under NDA, this matters.

### Disable the repo map entirely

```yaml
map-tokens: 0
```

No scan, no map, nothing sent. You manually add context with `/add` and `/read-only` as needed. **This is the recommended setting if you want full control over what the model sees.**

### Other scan controls

| Setting | Effect |
|---|---|
| `map-tokens: 0` | Disable repo map completely |
| `map-tokens: 1024` | Smaller/faster map (reduce what's sent) |
| `subtree-only: true` | Only scan current subdirectory, not entire repo |
| `map-refresh: manual` | Don't auto-refresh; only rebuild on explicit request |
| `.aiderignore` file | Exclude specific files/dirs from scanning (`.gitignore` syntax) |

### Running without git at all

```yaml
git: false
```

Disables all git awareness — no repo scan, no commits, no map. Useful for one-off file edits outside a repo.

**CLI one-off:**

```bash
aider --no-git --file somefile.py
```

**Note:** Aider is heavily git-oriented by design. Without git, you lose auto-commits, `/undo`, dirty-commit detection, and the repo map. For true one-off edits, lighter tools (e.g., Simon Willison's `llm` CLI, direct API calls, or a plain chat session) may be a better fit.

* * *

## Ask Mode (Read-Only / Planning Mode)

Aider has no explicit `--read-only` startup flag, but `ask` mode achieves the same effect: the model discusses and plans but **does not propose or make file edits**.

**In `~/.aider.conf.yml`:**

```yaml
edit-format: ask
```

**CLI flag:** `--edit-format ask` (alias: `--chat-mode ask`)

**Switch mid-session:** `/chat-mode ask` or just prefix any message with `/ask`.

**Switch back to editing:** `/chat-mode code` or `/chat-mode diff`.

### Recommended conservative config

For maximum control over what gets sent to the provider:

```yaml
model: claude-sonnet-4-6
edit-format: ask
map-tokens: 0
```

This starts aider in discussion mode with no automatic repo scanning. You add files explicitly as needed. Every piece of context the model receives is something you consciously provided.

### Other related modes

| Flag/Setting | Behavior |
|---|---|
| `edit-format: ask` | Discussion only, no edits |
| `--architect` | Two-step: model proposes high-level changes, editor model applies them |
| `--no-auto-accept-architect` | With `--architect`, requires your approval before editor applies changes |
| `--dry-run` | Model proposes edits but nothing is written to disk |
| `--read FILE` | Add file as read-only context (model sees it, can't edit it) |

### CLI flags → YAML config mapping

CLI flags map to YAML keys by stripping the `--` prefix. Hyphens stay as hyphens. Examples:

| CLI flag | YAML key |
|---|---|
| `--edit-format ask` | `edit-format: ask` |
| `--map-tokens 0` | `map-tokens: 0` |
| `--no-auto-commits` | `auto-commits: false` |
| `--no-git` | `git: false` |
| `--subtree-only` | `subtree-only: true` |
| `--dry-run` | `dry-run: true` |

The environment variable names confirm the pattern: `--edit-format` → `AIDER_EDIT_FORMAT`.

* * *

## Using Aider for Non-Code Files (Configs, HTML, Docs, etc.)

Aider works on any text file, not just source code. Explicitly supported use cases:

- Shell configs (`.bashrc`, `.zshrc`)
- SSH config (`~/.ssh/config`)
- Dockerfiles, `docker-compose.yml`
- Git config (`.gitconfig`)
- Editor configs (`.vimrc`, `settings.json`)
- Markdown documentation
- XML configs (`pom.xml`)
- Waybar configs, Hyprland configs, systemd units — anything text-based

**Usage pattern:** Just `aider <file>` and describe what you want changed. Works the same as code editing. For files you don't want edited (reference only), use `/read-only`.

* * *

## Thinking Tokens (Sonnet 3.7+)

Not enabled by default. Requires manual config in `~/.aider.model.settings.yml`:

```yaml
- name: anthropic/claude-3-7-sonnet-20250219
  edit_format: diff
  weak_model_name: anthropic/claude-3-5-haiku-20241022
  use_repo_map: true
  examples_as_sys_msg: true
  use_temperature: false
  extra_params:
    extra_headers:
      anthropic-beta: prompt-caching-2024-07-31,pdfs-2024-09-25,output-128k-2025-02-19
    max_tokens: 64000
    thinking:
      type: enabled
      budget_tokens: 32000
  cache_control: true
  editor_model_name: anthropic/claude-3-7-sonnet-20250219
  editor_edit_format: editor-diff
```

In-chat: `/think-tokens 8k` (or `8096`, `10.5k`, `0.5M`, `0` to disable).

`/reasoning-effort` — set effort level (number or low/medium/high depending on model).

* * *

## Prompt Caching

`--cache-prompts` enables caching (Anthropic Sonnet/Haiku, DeepSeek Chat). Caches system prompt, read-only files, repo map, and editable files.

`--cache-keepalive-pings N` — pings every 5 min to prevent cache expiry (Anthropic default TTL is 5 min). Pings `N` times over `N*5` minutes after each message.

`--no-stream` — required to see caching stats/costs (stats not available during streaming).

* * *

## Conventions Files

Create a `CONVENTIONS.md` (or any name) with project-specific rules. Load with:

```
/read-only CONVENTIONS.md
```

Or in `~/.aider.conf.yml` to always load:

```yaml
read: CONVENTIONS.md
# or multiple:
read: [CONVENTIONS.md, project-rules.md]
```

Loaded as read-only → cached if prompt caching is enabled. Good for coding style, library preferences, type hint requirements, etc.

Community conventions: check the aider conventions repository.

* * *

## Essential In-Chat Commands Quick Reference

| Command | What it does |
|---|---|
| `/ask` | Discuss/plan without editing files — **the "dry run"** |
| `/code` | Switch to edit mode (default) |
| `/architect` | Use 2-model architect/editor flow |
| `/add <file>` | Add file to chat for editing |
| `/read-only <file>` | Add file as reference only (not editable, cached) |
| `/drop <file>` | Remove file from chat |
| `/diff` | Show changes since last message |
| `/undo` | Revert last aider git commit |
| `/clear` | Clear chat history, fresh start |
| `/run <cmd>` | Run shell command, optionally share output |
| `/test <cmd>` | Run command, share output only on failure |
| `/lint` | Lint and fix in-chat files |
| `/web <url>` | Scrape URL to markdown, send as context |
| `/model <name>` | Switch model mid-session |
| `/tokens` | Show token usage for current context |
| `/paste` | Paste clipboard into chat |
| `/editor` | Open $EDITOR to compose message (`Ctrl-X Ctrl-E`) |
| `/multiline-mode` | Toggle: Enter=newline, Meta-Enter=submit |
| `/map` | Print repo map |
| `/save` | Save session commands to file for replay |
| `/load <file>` | Load and execute commands from file |

**Multi-line input:** `{` on its own line to start, `}` to end. Or `{tag` ... `tag}` if content contains braces. Meta-Enter for single newlines.

**Vi mode:** `aider --vim`

* * *

## Tips

- Add only files that need editing. Aider uses a repo map for context on everything else.
- Break complex changes into steps. `/drop` and `/add` as you go.
- `/ask` first for complex work, then "go ahead" to execute.
- If stuck: `/clear`, `/drop` extras, switch `/model`, or just code the next step yourself and let aider continue from there.
- To create a new file: `/add <newfile>` first, then describe what goes in it.
- Paste errors directly or use `/run` to share error output.
- `Control-C` to interrupt — partial response stays in context.

* * *

## Next Steps / Open Questions

*   Monitor aider releases for when `--model sonnet` alias updates to `claude-sonnet-4-6`.
*   Consider per-project `.aider.conf.yml` overrides for repos that need different models.
*   Explore using aider for Hyprland/waybar/systemd config editing workflows.

## References

*   Aider YAML config docs: https://aider.chat/docs/config/aider_conf.html
*   Aider API key docs: https://aider.chat/docs/config/api-keys.html
*   Aider options reference: https://aider.chat/docs/config/options.html
*   Aider tips: https://aider.chat/docs/usage/tips.html
*   Aider in-chat commands: https://aider.chat/docs/usage/commands.html
*   Aider prompt caching: https://aider.chat/docs/usage/caching.html
*   Aider conventions: https://aider.chat/docs/usage/conventions.html
*   Aider config/text editing: https://aider.chat/docs/usage/editing-config.html
*   joshuavial/aider.nvim: https://github.com/joshuavial/aider.nvim
*   Anthropic Sonnet 4.6 announcement: https://www.anthropic.com/news/claude-sonnet-4-6
*   API model identifier: `claude-sonnet-4-6`

* * *

## Additions

> Items added outside of a structured update. May be rough, incomplete, or shorthand.
> These should be integrated into the note body on the next formal update.

_(none yet)_