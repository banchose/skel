---
name: openrouter-mcp
description: Gotchas for the OpenRouter MCP server (mcp.openrouter.ai) via pi-mcp-adapter — model catalog, pricing, provider endpoints, rankings, benchmarks, credits, send-message/image/speech/transcribe, batch API, docs search. Use when querying OpenRouter model rankings, prices, provider endpoints, uptime, credit balance, or calling a model through OpenRouter.
disable-model-invocation: true
---

# OpenRouter MCP

Last verified live: 2026-10-31 (pi-mcp-adapter 7.0.0, 25 tools).

## Setup

- Server entry `openrouter` in **`~/.pi/agent/mcp-adapter.json`**, not `mcp.json`. The
  pi-mcp-adapter extension replaces Pi's built-in MCP support, so Pi doesn't read `mcp.json`.
  ```json
  "openrouter": { "url": "https://mcp.openrouter.ai/mcp", "type": "http",
    "headers": { "Authorization": "Bearer ${OPENROUTER_API_KEY}" }, "disabled": false }
  ```
- Auth is the static API key in the header. OAuth isn't usable here: the adapter stores OAuth
  tokens only in an OS keyring and fails closed without one, and the container has none. The
  static key has none of the OAuth key's limits: no 7-day expiry, no $10 cap, no re-auth.
- After editing the config, run `/reload`. `mcp({connect})` doesn't pick up new servers.
- Smoke test: `openrouter_ping` → `pong`. It may not need auth, so also run
  `openrouter_get-credits`, which proves the key works.

## How to call

The server isn't `directTools`, so call it through the proxy. Tool names carry the `openrouter_` prefix:

```
mcp__openrouter({ tool: "openrouter_list-models", args: { request: { sort: "pricing-low-to-high", limit: 10 } } })
mcp({ tool: "openrouter_list-models", args: { ... } })          // equivalent
```

- The result is the tool's JSON text as-is (`{"data": ..., "meta"/"total_count"/"links": ...}`).
  There's no `content[0].text` wrapper, and no `{ok, data}` wrapper either: that came from
  the adapter's old script tool, which has been removed.
- Scripting: the adapter's old `mcpScript` / `tools.call(...)` tool is gone. Its replacement
  is Pi's `codemode`, which is opt-in (add `"+codemode"` to `defaultTools`) and **not
  enabled** here. If it's enabled, call `tools.mcp__openrouter__list_models({...})`
  (`-` becomes `_`); the result is a full `CallToolResult`, so parse `content[0].text`.
- Schemas: `mcp({ describe: "openrouter_<tool>" })`, or read them for free from
  `~/.pi/agent/mcp-cache.json` → `servers.openrouter.tools[]` (names there have no prefix).

### Args: `request` wrapper or flat (check before calling)

| Shape | Tools |
|---|---|
| **Nested** `{request:{...}}` | list-models, get-model, list-model-endpoints, list-daily-model-rankings, list-app-rankings, list-benchmarks, list-task-classifications, get-generation, list-presets, get-preset, send-feedback |
| **Flat** | send-message, generate-image, generate-speech, transcribe-audio, search-docs, get-endpoint-uptime-history, send-batch, get-batch, list-batches |
| **No args** | ping, get-credits, list-providers, install-ori-harness, spawn-ori-eval |

`get-model`, `list-model-endpoints` and `get-endpoint-uptime-history` take `author` + `slug`
as separate fields (`amazon` + `nova-micro-v1`), not `amazon/nova-micro-v1`.

### Large results

The adapter's output guard cuts results at ~50 KB / 2000 lines, keeping the head. The full
text goes to `/tmp/pi-mcp-output-*/mcp-result-<hex>.txt`, and the result names that path.
Read the file with python/jq; don't repeat the call. Keep results small server-side instead:
`limit`, `sort` and filters on list-models; a short `start_date`/`end_date` window on rankings.

## Billable / state-changing (confirm with the user first)

`send-message`, `generate-image`, `generate-speech`, `transcribe-audio`, `send-batch`
(billed as each request completes), and `send-feedback` (a write). Everything else is
read-only (`readOnlyHint: true`).

## list-models (pricing and the catalog)

- **Prices are formatted strings**, not numbers: `"pricing":{"prompt":"$0.035/M tokens","completion":"$0.14/M tokens"}`.
  To compare, parse out the number. Some models also have `overrides` (higher prices above
  `min_prompt_tokens`), plus cache-read/write and `web_search` prices.
- Sort and filter on the server, as the tool description recommends: `sort` = `pricing-low-to-high`
  (by the average of prompt and completion price), `newest`, `top-weekly`, `intelligence-high-to-low`,
  `coding-high-to-low`, `context-high-to-low`, and others. Filters: `min_price`/`max_price` (prompt $/M),
  `min_output_price`/`max_output_price`, `context`, `category`, `model_authors`, `providers`, `q`,
  `supported_parameters`, `zdr`, `region`, `input_modalities`/`output_modalities` (default `text`).
  The response has `total_count` and `links.next` for paging.
- **`:batch` variants appear in the results** (e.g. `anthropic/claude-haiku-5.5:batch`). They have
  `endpoints: []` and work only through `send-batch`. Leave them out of interactive picks.
- **Free models weren't found** (2026-10-31): `max_price: 0` and `q: "free"` both returned
  `total_count: 0`, and the unfiltered catalog had only 73 entries with no `:free` ids, though the
  rankings show plenty of `:free` models. I didn't find out why. For free options, use rankings
  slugs that end in `:free`; don't conclude from list-models that none exist.

## Capability checks: model-level `supported_parameters` is incomplete

`tool_choice` (and sometimes `structured_outputs`) can be missing from `supported_parameters`, at
**both** the model and endpoint level, on models that support it. Verified: `amazon/nova-micro-v1`
leaves out `tool_choice` everywhere, yet both endpoints report
`supports_tool_choice: {none, auto, required, function}` all `true`. Other models (e.g. Claude Haiku 5.5)
do list it. **Before saying a model lacks a feature, check `list-model-endpoints`.** Its per-provider
records also give price, `quantization`, `uptime_last_*`, latency/throughput percentiles, and `tag`
(the provider slug to use in routing).

## Rankings (`list-daily-model-rankings`)

- Response: `{data:[{date, model_permaslug, total_tokens}], meta:{as_of, start_date, end_date}}`.
  `total_tokens` is a **string**, so convert it with `int()` before sorting.
- Rows group into buckets by `date`, about 50 models per bucket, plus an **`other`** row that
  isn't a model. Rank within `max(date)` only.
- The **latest bucket is usually partial** (a week that started 10-26 with `end_date` 10-30).
  Compare the last *complete* bucket, or say that the latest one is partial.
- Permaslugs are dated (`deepseek/deepseek-v4.1-flash-20261017`), and one model can show up under
  two dates (a re-release). Add them together if you want per-model totals.
- Default window: 30 days ending yesterday (UTC); `start_date`/`end_date` are YYYY-MM-DD,
  floor 2025-01-01. A 30-day weekly query is ~25 KB, which still comes back inline; longer
  windows go to the temp file.
- 400s (verified):
  - `category` or `language_type` together with `period: "day"` → sampled data is weekly
    only. Use `week` (the default for these) or `month`.
  - `category` or `language_type` together with `modality` or `context_bucket` → you can't mix
    sampled and exact filters.
  - `category` + `language_type` → the two come from different sampled datasets, so pass only one.
- Enums: `category` ∈ programming, roleplay, marketing, marketing/seo, technology, science,
  translation, legal, finance, health, trivia, academia. `modality` ∈ text, image, image_output,
  audio, tool_calling. `context_bucket` ∈ 1K, 10K, 100K, 1M, 10M. `language_type` ∈ natural, programming.

## send-message

- Flat args: `model`, `message`, optional `system`, `provider` (`order`/`only`/`ignore`/
  `allow_fallbacks`/`sort`; leave it unset unless you need reproducibility), `reasoning_effort`
  (max…none), `max_tokens` (the best brake on reasoning models), `timeout_ms`.
- Slug suffixes: `:online` (web search), `:nitro` (throughput), `:floor` (cheapest), `:free`.
- The output includes a generation id. Pass it to `get-generation` (`{request:{id}}`) for the
  real cost, tokens and provider.
- Never pick a model from memory for "which model should I use". Use `list-benchmarks`,
  `list-daily-model-rankings` and `list-models`.

## Batch API

`send-batch` (flat: `endpoint` ∈ `/v1/chat/completions` | `/v1/responses` | `/v1/messages` | `/v1/embeddings`,
`model`, `requests[]`; at most 1000 requests / 8 MB per call; optional `provider_only`) gets discounted
pricing, with results within 24 h. It returns a batch id with status `validating`. Poll it with
`get-batch` (`{id}`) and list batches with `list-batches` (`limit`, `after`, `status[]`).

## Other shapes

- `get-credits` → `{"data":{"total_credits":N,"total_usage":N}}`. Remaining = credits − usage.

## Tool map (25)

- Catalog/pricing: `list-models`, `get-model`, `list-model-endpoints`, `list-providers`, `get-endpoint-uptime-history`
- Inference: `send-message`, `generate-image`, `generate-speech`, `transcribe-audio`
- Batch: `send-batch`, `get-batch`, `list-batches`
- Cost: `get-credits`, `get-generation`
- Research: `list-benchmarks`, `list-daily-model-rankings`, `list-app-rankings`, `list-task-classifications`, `search-docs`
- Misc: `list-presets`, `get-preset`, `send-feedback`, `ping`, `install-ori-harness`, `spawn-ori-eval`
