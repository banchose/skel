# llm CLI Configuration & Troubleshooting

## Model ID Format — Do Not Mix Notations

| Plugin | Format | Example |
|---|---|---|
| `llm-anthropic` | `anthropic/claude-sonnet-4-5` | dash between version parts |
| `llm-openrouter` | `openrouter/anthropic/claude-sonnet-4.6` | dot between version parts |

These are not interchangeable. Using the wrong format produces:
```

Error: 'Unknown model: anthropic/claude-sonnet-4-6'

````

## Plugin Capability Boundaries

| Option | Valid For | Error if misused |
|---|---|---|
| `-o online 1` | `llm-openrouter` only | `Error: online — Extra inputs are not permitted` |
| `-T Exa` | Any plugin (tool invocation) | Requires `EXA_API_KEY` in `llm keys` |

Do not use `-o online 1` with `llm-anthropic` — it will always fail. Use `-T Exa` instead for web search via the Anthropic plugin.

## Key Storage vs Environment Variables

`llm` maintains its own key store (`keys.json`) separate from shell env vars.
Having `EXA_API_KEY` set in the environment does **nothing** until it is explicitly loaded:

```bash
llm keys set exa --value "${EXA_API_KEY}"
````

Symptom of missing key store entry: Exa tool reports API key error despite env var being set.  
Diagnosis: `llm keys get exa` returns empty.

Key store location:

```bash
llm keys path
# Linux: ~/.config/io.datasette.llm/keys.json
```

`llm keys set` uses `--value`, not `-v`:

```bash
# Correct
llm keys set exa --value "${EXA_API_KEY}"
# Wrong — fails silently or errors
llm keys set exa -v "${EXA_API_KEY}"
```

Auto-load pattern at shell startup (mirror for each key):

```bash
llm_set_exa_key() {
  [[ -z "${EXA_API_KEY}" ]] && {
    printf 'WARNING: EXA_API_KEY is not set\n' >&2
    return 1
  }
  command llm keys set exa --value "${EXA_API_KEY}"
}
```

## Template-First Workflow

Prefer templates over spelling out `-m`, `-s`, `-T` on every alias.  
A template bundles model + system prompt + tools into a single `.yaml` file.

```bash
llm -t default_anthropic_sonnet "my prompt"
# vs
llm -m anthropic/claude-sonnet-4-5 -s "system..." -T web_search -T get_answer "my prompt"
```

Template location:

```bash
llm templates path
# Linux: ~/.config/io.datasette.llm/templates/
```

Minimal working template (`default_anthropic_sonnet.yaml`):

```yaml
model: anthropic/claude-sonnet-4-5
system: |
  Your system prompt here.
tools:
  - llm_version
  - llm_time
  - simple_eval
  - web_search
  - get_answer
  - get_contents
```

Bootstrap function (safe, no-overwrite):

```bash
llm_create_default_template() {
  local tpath
  tpath="$(command llm templates path)"
  local tfile="${tpath}/default_anthropic_sonnet.yaml"
  if [[ -f "${tfile}" ]]; then
    printf 'Template already exists: %s\n' "${tfile}"
    return 0
  fi
  cat > "${tfile}" <<'EOF'
model: anthropic/claude-sonnet-4-5
system: |
  Your system prompt here.
tools:
  - web_search
  - get_answer
  - get_contents
EOF
  printf 'Created: %s\n' "${tfile}"
}
```

## Guard: Don't Source if llm Is Not Installed

Place at the top of any sourced shell script that depends on `llm`:

```bash
command -v llm >/dev/null 2>&1 || {
  printf 'WARNING: llm not found in PATH — skipping llm-cli.sh\n' >&2
  return 0
}
```

## Diagnostic Aliases

```bash
alias llm_what_tools='llm -t default_anthropic_sonnet "What tools do you have access to?"'
alias llm_what_version='llm -t default_anthropic_sonnet "What LLM model version are you?"'
```

## Quick Status Check

```bash
llm_status() {
  printf '=== default model ===\n'
  command llm models default
  printf '=== stored keys ===\n'
  command llm keys
  printf '=== env vars ===\n'
  printf 'ANTHROPIC_API_KEY:       %s\n' "${ANTHROPIC_API_KEY:0:15}"
  printf 'OPENROUTER_API_KEY:      %s\n' "${OPENROUTER_API_KEY:0:15}"
  printf 'EXA_API_KEY:             %s\n' "${EXA_API_KEY:0:15}"
}
```

## Troubleshooting Quick Reference

| Symptom | Cause | Fix |
| --- | --- | --- |
| `Unknown model: anthropic/claude-sonnet-4-6` | Wrong model ID format | Use `anthropic/claude-sonnet-4-5` |
| `Extra inputs are not permitted` | `-o online 1` used with `llm-anthropic` | Use `-T Exa` or switch to OpenRouter alias |
| Exa tool reports missing API key | Key in env but not in `llm keys` | `llm keys set exa --value "${EXA_API_KEY}"` |
| `llm keys get exa` returns empty | Key never stored | Same as above |
| `No such option: -v` | Wrong flag for `llm keys set` | Use `--value` |
| Template not found | `.yaml` mis
