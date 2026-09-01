---
name: openrouter-mcp
description: Gotchas for the OpenRouter MCP server (mcp.openrouter.ai) — model catalog, pricing, rankings, credits, send-message/image/speech/transcribe, docs search. Use when querying OpenRouter model rankings, prices, provider endpoints, uptime, credit balance, or calling a model through OpenRouter.
---

# OpenRouter MCP

Configured in `~/.pi/agent/mcp.json` with `Authorization: Bearer ${OPENROUTER_API_KEY}`.
22 tools, all prefixed `openrouter_`. OAuth does not work here (no OS keyring) — key only.
Static key = no 7-day expiry / $10 cap that the OAuth flow imposes, and no re-auth step.
Read-only except `send-message`, `generate-image`, `generate-speech`, `transcribe-audio` (billable inference)
and `send-feedback` (writes).

## Three gotchas that cost calls

1. **Tool names have no server prefix in `mcpScript`.** Use `tools.call('openrouter_list-models', {})`,
   not `'openrouter/openrouter_list-models'` → `tool_not_found`.
2. **Most tools nest args under `request`:** `{request:{category:'programming', period:'week'}}`.
   Always `tools.describe({path:'openrouter_<tool>'})` first; the error text also dumps the full param list.
3. **Responses are big** (rankings ≈ 190KB, 33 weeks × ~50 models). Anything over the size limit is
   written to `/tmp/pi-mcp-output-*/mcp-result-*.txt` — read that path with python/jq, don't retry the call.
   Payload shape: `data.content[0].text` is a **JSON string**; parse it, then `["data"]` is the row array.

## Capability checks: never trust model-level `supported_parameters`

It is not the whole story. `tool_choice` is absent from that array even on models that fully support it —
the truth lives per-endpoint in `openrouter_list-model-endpoints` as `supports_tool_choice:
{none, auto, required, function}`. Same for `structured_outputs`, which can differ between providers of the
same model. Before claiming a model lacks a feature, check the endpoints call.

## Rankings specifics

`openrouter_list-daily-model-rankings` — rows are `{date, model_permaslug, total_tokens}` (tokens are strings).
- `category` or `language_type` → weekly-sampled dataset: `period=day` is rejected 400. Use `week`/`month`.
- `category` cannot combine with `modality`, `context_bucket`, or `language_type`.
- Defaults to a 30-day window; pass `start_date`/`end_date` (YYYY-MM-DD, floor 2025-01-01).
- Latest bucket only: filter to `max(date)` before ranking, and there's an `other` bucket row — don't read it as a model.

## send-message

Slug suffixes work: `:online` (web search), `:nitro` (speed), `:floor` (cheapest), `:free`.
Every reply carries a generation id — pass it to `get-generation` for real cost/provider.
Never name a model from memory for "which model should I use" — use `list-benchmarks`,
`list-daily-model-rankings`, `list-models`.

## Tool map

- Catalog/pricing: `list-models`, `get-model`, `list-model-endpoints`, `list-providers`, `get-endpoint-uptime-history`
- Inference: `send-message`, `generate-image`, `generate-speech`, `transcribe-audio`
- Cost: `get-credits`, `get-generation` (per-call cost/tokens/provider)
- Research: `list-benchmarks`, `list-daily-model-rankings`, `list-app-rankings`, `list-task-classifications`, `search-docs`
- Misc: `list-presets`, `get-preset`, `send-feedback`, `ping`, `install-ori-harness`, `spawn-ori-eval`
