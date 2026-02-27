# llm-cli.sh — Maintenance Notes

**File:** `~/gitdir/skel/bash/bashrc_zen.d/llm-cli.sh`  
**Purpose:** Sourced into interactive Bash shell. Provides aliases, functions, and env var exports for working with `llm` CLI, OpenRouter, Anthropic, AWS Bedrock, and LiteLLM proxy.

* * *

## Key Facts

*   **Sourced file, not a script** — runs in the current shell, not a subshell.
    
*   **Environment:** Ubuntu 24.04 (WSL2), Bash 5.2
    
*   **Templates:** Managed as symlinks from the git repo (source of truth) into `~/.config/io.datasette.llm/templates/`. The `llm_symlink_templates` alias handles this.
    

* * *

## Recurring Issues & Fixes

### 1. `exit` vs `return` in functions

*   Functions in a sourced file must use `return`, not `exit`.
    
*   `exit` kills the interactive shell session.
    
*   **Affected:** `START_LOCAL_LITELLM()` was originally a standalone script appended to this file. All `exit 1` had to become `return 1`.
    

### 2. `set -euo pipefail` / `set -x` in functions

*   These modify the **current shell's** options and persist after the function returns.
    
*   `set -x` left the interactive shell in trace mode after litellm exited or was Ctrl+C'd.
    
*   `set -euo pipefail` is inappropriate inside sourced functions — use explicit guard clauses instead.
    
*   **Fix:** Removed both. Guard clauses (`command -v`, `aws sts`, `ss`, file existence checks) handle error paths.
    

### 3. `set -u` (`nounset`) protection on environment variables

Variables referenced in this file may be unset. Under `set -u`, bare `${VAR}` expansion of an unset variable causes an immediate error. This file must be safe regardless of whether `set -u` is active elsewhere in the shell init.

**Expansion operators used:**

| Operator | Meaning | Use case |
| --- | --- | --- |
| `${VAR:-}` | Empty string if unset | Guard clauses: `[[ -z "${VAR:-}" ]]` |
| `${VAR:-default}` | Fallback value if unset | Display: `${AWS_BEDROCK_DEFAULT_MODEL:-(not set)}` |
| `${VAR:+alt}` | Expand to `alt` only if set and non-null | Truncated display: `${VAR:+(${VAR:0:15}…)}` |
| `${VAR:?msg}` | Abort with error if unset | Required values: `${VAR:?VAR is not set}` |
| `${VAR+x}` | Expand to `x` if set (even if empty) | Set-vs-unset test (used in `llm_set_bedrock_model`) |

**Pattern:** Use `:-` in guards, `:+` for optional display, `:?` where the value is required for the command to be meaningful, and bare `${VAR}` only _after_ a guard has confirmed the variable exists.

**Common mistake:** Adding `:-` to a line that _uses_ the value (e.g., `llm keys set exa --value "${EXA_API_KEY:-}"`). This would silently pass an empty string. The guard above should `return 1` before reaching this line — leave it bare.

### 4. `local` in functions

*   Without `local`, variables assigned in functions leak into the shell environment.
    
*   **Affected:** `START_LOCAL_LITELLM()` — `LITELLM_CONFIG_DIR`, `LITELLM_CONFIG`, `LITELLM_PORT`, `AWS_PROFILE_NAME` all needed `local`.
    

### 5. Shebang inside functions

*   `#!/usr/bin/env bash` inside a function body is parsed as a comment — harmless but misleading. Remove it.
    

### 6. `local` declared once per function, not inside loops

*   `local` in Bash is only meaningful at declaration time within function scope.
    
*   Re-declaring `local var` inside a loop body is a no-op — works but is misleading.
    
*   **Pattern:** Declare all locals at the top of the function, assign in the loop body.
    

### 7. WSL2: `localhost` fails in `curl` inside functions

*   `curl` against `http://localhost:4000/health` returned HTTP code `000` (connection failure) when run inside the `llm_status` function, while the identical command succeeded interactively.
    
*   `000` from `curl` means the TCP connection itself failed — no response was received.
    
*   **Root cause:** WSL2 DNS resolution of `localhost` is unreliable. It may resolve to `::1` (IPv6 loopback) which the service doesn't bind to, or fail entirely depending on shell context. The service binds to `0.0.0.0:4000` (IPv4 only).
    
*   **Diagnosis:** Replacing `localhost` with `127.0.0.1` in the same `curl` command returned `200` immediately, both interactively and inside the function.
    
*   **Fix (2026-02-26):** Changed all programmatic health checks to use `127.0.0.1` instead of `localhost`. Applies to both `llm_status` and the port-check hint in `START_LOCAL_LITELLM`.
    
*   **Rule:** In WSL2, always use `127.0.0.1` for loopback in scripts and functions. Reserve `localhost` for interactive/human use only if at all.
    

### 8. `Error: 'Unknown model: brs'` — missing `extra-openai-models.yaml`

*   The `brs` model ID is defined in `extra-openai-models.yaml`, **not** via `llm aliases` or a plugin. If this file is missing from `~/.config/io.datasette.llm/`, `llm` has no knowledge of the model and reports `Unknown model: brs`.
    
*   **This error is misleading** — it looks like a model name typo or plugin issue, but the actual cause is a missing config file. The proxy being up/down and AWS login state are irrelevant; `llm` fails before it ever tries to connect.
    
*   The file is maintained in the skel repo at `~/gitdir/skel/llm/litellm/extra-openai-models.yaml` and must be symlinked into the config directory.
    
*   **Fix:** Run `llm_bootstrap` (or manually symlink):
    
    ```bash
    ln -s ~/gitdir/skel/llm/litellm/extra-openai-models.yaml ~/.config/io.datasette.llm/extra-openai-models.yaml
    ```
    
*   **First occurrence:** 2026-02-27 — new workstation had litellm running and AWS SSO active, but the symlink had never been created.
    
*   **Prevention:** Run `llm_bootstrap` on any new machine. The `brs` function (replacing the old alias) now checks proxy and AWS session before calling `llm`, but the `extra-openai-models.yaml` symlink is a prerequisite for `llm` to even recognize the model ID.
    

* * *

## `llm_status` — Design (as of 2026-02-26)

**Goal:** Sit down at any machine and immediately know what's configured, what's running, and what's broken — without hunting through the output.

### Key design decisions

*   `==>` **prefix on problem lines** — visually jumps out while scanning. Healthy lines use 4-space indent to stay aligned.
    
*   **Issue summary at the bottom** — replays the problem list so you see the count _and_ what's wrong without scrolling back.
    
*   **LiteLLM DOWN → show start command** — don't just say it's broken, show how to fix it.
    
*   `-n` **flag on any test prompts** — avoids polluting the log database with health check pings.
    
*   **Return code** — `return 1` if any issues, so it's scriptable.
    
*   **No token cost** — `llm_status` never sends a prompt. Use `llm_test_bedrock` for live reachability.
    

### Current implementation (in file)

```bash
llm_status() {
  local -i issues=0
  local var val http_code
  local -a issue_msgs=()
  printf '=== default model ===\n'
  command llm models default
  printf '=== logging ===\n'
  command llm logs status
  printf '=== stored keys ===\n'
  command llm keys
  printf '=== stored templates ===\n'
  command llm templates
  printf '=== installed plugins ===\n'
  command llm plugins | python3 -c "
import sys, json
for p in json.load(sys.stdin):
    print(f\"  {p['name']:30s} {p.get('version', '?')}\")" 2>/dev/null ||
    printf '  (could not parse)\n'
  printf '=== env vars ===\n'
  for var in ANTHROPIC_API_KEY OPENROUTER_API_KEY AWS_BEARER_TOKEN_BEDROCK \
    AWS_BEDROCK_DEFAULT_MODEL EXA_API_KEY; do
    val="${!var:-}"
    if [[ -z "${val}" ]]; then
      printf '==> %-26s %s\n' "${var}:" "NOT SET"
      issue_msgs+=("${var} not set")
      ((issues++)) || true
    elif [[ "${#val}" -gt 20 ]]; then
      printf '    %-26s(%s…)\n' "${var}:" "${val:0:15}"
    else
      printf '    %-26s%s\n' "${var}:" "${val}"
    fi
  done
  printf '=== litellm proxy ===\n'
  http_code=$(curl -s -o /dev/null -w '%{http_code}' \
    --connect-timeout 2 --max-time 3 \
    http://127.0.0.1:4000/health 2>/dev/null) || true
  printf 'DEBUG: http_code=[%s]\n' "${http_code}" >&2
  if [[ "${http_code}" == "200" ]]; then
    printf '    127.0.0.1:4000 — UP\n'
  else
    printf '==> 127.0.0.1:4000 — DOWN\n'
    printf '    start: ~/gitdir/skel/llm/litellm/START_LOCAL_LITELLM.sh\n'
    printf '    or:    litellm -c ~/gitdir/skel/llm/litellm/litellm.conf --port 4000\n'
    issue_msgs+=("litellm proxy not running")
    ((issues++)) || true
  fi
  if ((issues > 0)); then
    printf '\n%d issue(s):\n' "${issues}"
    local msg
    for msg in "${issue_msgs[@]}"; do
      printf '  ==> %s\n' "${msg}"
    done
    return 1
  fi
  return 0
}
```

* * *

## Model Aliases (as of 2026-02-26)

All aliases now include `-u` (show token usage).

| Prefix | Backend | Model ID | Notes |
| --- | --- | --- | --- |
| `bro` / `bron` / `bros` / `broT` | LiteLLM → Bedrock | `bro` | `extra-openai-models.yaml` config |
| `brs` / `brsn` / `brss` / `brsT` | LiteLLM → Bedrock | `brs` | Distinct from native `bedrock-sonnet` [2] |
| `brh` / `brhn` / `brhs` / `brhT` | LiteLLM → Bedrock | `brh` |  |
| `ort` / `orts` / `orte` | OpenRouter | `${OPENROUTER_DEFAULT_MODEL}` | `orts` = online search, `orte` = Exa |
| `ant` / `antx` / `antxs` | Anthropic | `${ANTHROPIC_DEFAULT_MODEL}` | `ant` uses template |
| `llma` | Anthropic | `${ANTHROPIC_DEFAULT_MODEL}` | Uses `-t default` template |

**Tool bundles:**

*   Bare alias (e.g., `bro`): Now uses `-t bro` (template), which includes tool configuration
    
*   `s` suffix (e.g., `bros`): `-T web_search` instead of `-T Exa`, plus `-T simple_eval -T llm_version -T llm_time -T get_answer -T get_contents`
    
*   `n` suffix (e.g., `bron`): No tools, just model + `-u`
    
*   `T` suffix (e.g., `broT`): Quick test prompt
    

### Exported model env vars

| Variable | Value |
| --- | --- |
| `OPENROUTER_DEFAULT_MODEL` | `openrouter/anthropic/claude-sonnet-4.6` |
| `ANTHROPIC_DEFAULT_MODEL` | `anthropic/claude-sonnet-4-5` |
| `AWS_BEDROCK_DEFAULT_SONNET_MODEL` | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| `AWS_BEDROCK_DEFAULT_OPUS_MODEL` | `us.anthropic.claude-opus-4-1-20250805-v1:0` |
| `OPENROUTER_DEFAULT_SONNET_MODEL` | `openrouter/anthropic/claude-sonnet-4.6` |
| `OPENROUTER_DEFAULT_OPUS_MODEL` | `openrouter/anthropic/claude-opus-4.6` |
| `CLAUDE_CODE_USE_BEDROCK` | `1` |

* * *

## Cleanup TODO

- [ ] **Remove** `START_LOCAL_LITELLM` **function from llm-cli.sh** — standalone script `~/gitdir/skel/llm/litellm/START_LOCAL_LITELLM.sh` is the canonical version. Having both means maintenance divergence.

- [ ] **Remove noisy** `echo "EXPORTING..."` **lines** — every `exec bash` produces a wall of text. The env vars export silently; use `llm_status` to inspect on demand.

- [ ] **Remove** `echo "NOT SETTTING..."` **block** at the bottom (also has a typo: three T's). Replace with a comment if needed.

- [ ] **Deduplicate alias sprawl** — `orts`/`orte`/`ort`/`llmos`/`llmose`/`llm_ort_srch` all overlap. Pick one short name per backend+mode.

- [ ] `llm_set_default_template` — add trailing `/` to cp destination so it fails clearly if path isn't a directory: `cp *.yaml "${tpath}"/`

- [ ] `llm_test_bedrock` — consider slimming to just the live prompt test with `-n --no-stream`. Diagnostic dump is now handled by `llm_status`.

- [ ] **Remove** `DEBUG:` **line from** `llm_status` — was added during the `localhost` vs `127.0.0.1` investigation. No longer needed now that the fix is confirmed.

* * *

## File Structure (as of 2026-02-26)

1.  **Environment variable checks** — warns on missing keys at source time
    
2.  **Alias:** `llmedit` — opens this file in nvim
    
3.  **Test variable:** `llmtst` — quick test string for web search
    
4.  **Exports** — model names, feature flags (`CLAUDE_CODE_USE_BEDROCK`)
    
5.  **Aliases** — shortcuts for `llm` with various providers/models, organized by backend:
    
    *   `llm_symlink_templates` — symlink templates from git repo into llm config dir
        
    *   `llm_png` — clipboard image via `wl-paste`
        
    *   OpenRouter aliases (`ort`, `orts`, `orte`, etc.)
        
    *   Anthropic aliases (`ant`, `antx`, `antxs`, `llma`, etc.)
        
    *   Bedrock/LiteLLM aliases (`bro`, `brs`, `brh` families)
        
6.  **Plugin install comments** — reference list of `llm install` commands for all used plugins
    
7.  **Functions:**
    
    *   `llm_set_openrouter_key` / `llm_set_anthropic_key` / `llm_set_exa_key` — load env var keys into `llm keys`
        
    *   `llm_set_default_template` — copy YAML templates into llm template path
        
    *   `llm_set_bedrock_model` — set llm default model to Bedrock
        
    *   `llm_test_bedrock` — diagnostics + test prompt
        
    *   `llm_status` — health check: model, keys, env vars, templates, plugins, logging, litellm proxy with `==>` issue markers and summary
        
    *   `llmbed` — prompt via Bedrock with date context
        
    *   `llm_help` — reference card (includes flags, fragment commands, custom functions, note that model name drives key selection)
        
    *   `START_LOCAL_LITELLM` — start LiteLLM Bedrock proxy (**remove — use standalone script**)
        
8.  **Source-time output** — prints truncated API key prefixes (**candidate for removal**)
    

* * *

## Checklist for Future Edits

- [ ] Any new function: use `return` not `exit`

- [ ] Any new function: `local` all variables, declared once at top

- [ ] Any new env var reference: protect with appropriate `:-` / `:+` / `:?` operator

- [ ] Do not put `set -euo pipefail` or `set -x` in functions (or scope in subshell)

- [ ] After guard clause confirms variable is set, bare `${VAR}` is correct — do not add `:-`

- [ ] Avoid `local` redeclaration inside loops — declare at function top, assign in body

- [ ] Use `127.0.0.1` not `localhost` for loopback in all programmatic/scripted contexts (WSL2)