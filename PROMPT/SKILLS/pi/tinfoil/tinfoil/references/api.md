# Tinfoil Inference API

OpenAI-compatible. Everything below applies to chat unless noted.

## Connecting

| Connection | Base URL | Verification |
| --- | --- | --- |
| Tinfoil SDK | set by SDK (resolves to a router, e.g. `https://router-0.tinfoil.sh/v1`) | connection-time attestation + EHBP |
| Tinfoil Proxy | `http://127.0.0.1:3301/v1` | connection-time (proxy does it) |
| Direct HTTPS | `https://inference.tinfoil.sh/v1` | audit-time only (trusts TLS cert) |

Auth: `Authorization: Bearer $TINFOIL_API_KEY` (keys look like `tk_…`).
Observed 2026-10-23: the SDK's `getBaseURL()` returned `https://router-0.tinfoil.sh/v1`
on one run and `https://inference.tinfoil.sh/v1` on another — router selection
is per-connection (from the attestation bundle); don't hard-code either.

## Endpoints (from live `/v1/models`)

| Endpoint | Models |
| --- | --- |
| `/v1/chat/completions` | all chat models, `voxtral-small-24b` (audio-in chat), `websearch` tool |
| `/v1/responses` | all chat models except `llama3-3-70b` |
| `/v1/models` | catalog with pricing, context, `reasoning_params` — see [models.md](models.md) |
| `/v1/embeddings` | `nomic-embed-text` |
| `/v1/audio/transcriptions` | `whisper-large-v3-turbo`, `voxtral-small-24b` |
| `/v1/audio/translations` | `voxtral-small-24b` |
| `/v1/audio/speech` | `qwen3-tts`, `voxtral-tts` |
| `/v1/realtime` (WebSocket) | `voxtral-mini-4b-realtime` |
| `/v1/decisions` | `decision-small/medium/large` (experimental) |
| `/v1/convert/file` | `doc-upload` (document → text) |
| `/redact` | `pii-filter` |

`model: "auto"` lets the router pick a chat model.

## Reasoning effort

Pass `reasoning_effort` (string) on the request. **Unsupported value ⇒ HTTP 400.**

| Model | Accepted values | Notes |
| --- | --- | --- |
| `kimi-k3` | `low`, `high`, `max` | always reasons; **defaults to `max`** if omitted |
| `glm-5-3` | `low`, `high`, `max` | always reasons; defaults to `max`; ignores `enable_thinking` |
| `deepseek-v4-1-flash` | `none`, `low`, `high`, `xhigh`, `max` | `none` disables |
| `gemma4-31b` | `none`, `minimal`, `low`, `medium`, `high`, `xhigh`, `max` | |
| `gpt-oss-120b`, `gpt-oss-safeguard-120b` | `low`, `medium`, `high` | Harmony format; `none`/`minimal`/`xhigh`/`max` ⇒ 400 |
| `llama3-3-70b` | accepts param, no trace | not a reasoning model |

- Reasoning trace comes back in `message.reasoning`, separate from `content`.
  May be `null`/empty (GLM on simple prompts) — treat as valid.
- Reasoning tokens count toward `max_tokens`; docs suggest ~20K+ budget for
  tool-calling at default effort.
- `/v1/models` also exposes `reasoning_params.effort_map` (a coarse
  low/medium/high → model-native mapping) and the exact
  `chat_template_kwargs` the router sends. Example (deepseek):
  `{"low":"low","medium":"high","high":"xhigh"}`.

## Message roles

- `system`, `user`, `assistant`, `tool` work.
- **`developer` role is rejected** (`400 Unknown message role`). Clients that
  default to `developer` for reasoning models (OpenAI-style) must downgrade to
  `system`.
- OpenAI's `store` parameter is not supported — omit it.

## Prompt caching

- Automatic; router reuses KV state for a matching **model + prefix** within a
  cache namespace = (API identity, `user_cache_secret`).
- SDKs inject `user_cache_secret` into POSTs to `/v1/chat/completions`,
  `/v1/completions`, `/v1/responses`. Default secret is generated and persisted
  at `~/.tinfoil/user_cache_secret` (or `TINFOIL_USER_CACHE_SECRET` env).
- Minimum prompt length ≈ a few thousand chars; matched in fixed-size chunks so
  `usage.prompt_tokens_details.cached_tokens` can be less than the real prefix.
- Lives only in model-enclave GPU memory; evicted in minutes-to-hours; never on
  disk. Put stable content (system prompt, tools) first.
- Cached input is billed at the `cachedInputTokenPricePer1M` rate (only some
  models list one — see models.md).

## Errors

Standard OpenAI errors pass through (`AuthenticationError`, `RateLimitError`,
`BadRequestError`, …).

| Status | `code` | Meaning |
| --- | --- | --- |
| 401 | `invalid_api_key` | bad key |
| 429 | `insufficient_quota` | **per-key lifetime cap** hit (`max_cost`, `max_input_tokens`, `max_output_tokens`) — not transient, retrying won't help; raise cap or use another key |
| 402 | `insufficient_quota` | org/account has no balance or inactive subscription |
| 400 | — | unsupported `reasoning_effort`, unknown role, etc. |

Limits are evaluated on already-recorded usage, so in-flight requests complete
and a few seconds of new requests may still succeed after the cap.

SDK-side errors: `ConfigurationError` (fix code), `FetchError` (attestation
materials unreachable — retry), `AttestationError` (verification failed — retry;
persistent ⇒ possible real security issue). All extend `TinfoilError`.

## Billing

Per-token (`inputTokenPricePer1M`, `outputTokenPricePer1M`, optional cached
rate) for chat; per-request (`requestPrice`) for tools/audio/doc endpoints.
Usage metadata (token counts, model, timestamp) is reported by the router to the
control plane — content is not.
