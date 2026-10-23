---
name: tinfoil
description: "Knowledge base for Tinfoil (tinfoil.sh) — private AI inference in hardware enclaves — and its Pi provider extension. Covers the OpenAI-compatible API, live model catalog with pricing/context/reasoning_effort vocabularies, attestation/EHBP verification, the `tinfoil` JS SDK (TinfoilAI, SecureClient), CLI, proxy, error/quota codes, and the thinking-level maps in ~/.pi/agent/extensions/tinfoil. Use when the user asks about Tinfoil, its models (glm-5-3, kimi-k3, deepseek-v4-1-flash, gpt-oss-120b, gemma4-31b, llama3-3-70b), enclave privacy/attestation, the tinfoil/* provider in Pi, or when debugging a Tinfoil 400/429/AttestationError."
---

# Tinfoil

Tinfoil serves open-weight models inside AMD SEV-SNP / Intel TDX confidential VMs
(NVIDIA CC GPUs). The SDK attests the **router** enclave on every connection and
HPKE-encrypts request bodies to it (EHBP); the router attests each model enclave.
Tinfoil sees billing metadata + network metadata only — never prompts/completions.
Nothing is retained after the response (except prompt-cache KV in enclave GPU RAM).

## Quick facts

- Direct base URL `https://inference.tinfoil.sh/v1` (audit-time verification only);
  SDK picks a router per connection (seen: `router-0.tinfoil.sh`, `inference.tinfoil.sh`); local proxy
  `http://127.0.0.1:3301/v1`. Auth `Authorization: Bearer $TINFOIL_API_KEY` (`tk_…`).
- Key is in this container's env as `TINFOIL_API_KEY`. **Never print it.**
- `tinfoil` CLI is **not** installed here. Use the JS SDK via
  `~/.pi/agent/extensions/tinfoil/node_modules` — run scripts *from that directory*
  (Node resolves imports relative to the script, not cwd). See `scripts/models.sh`.
- Docs: every page at `https://docs.tinfoil.sh/<path>.md`; index `https://docs.tinfoil.sh/llms.txt`.

## Chat models (snapshot 2026-10-23 — `references/models.md` for full table)

| ID | ctx | $in/$out per 1M | vision | reasoning_effort values |
|---|---:|---|:-:|---|
| `glm-5-3` | 1M | 1.80 / 5.75 (cache 0.45) | – | `low`,`high`,`max` — **always reasons, default max** |
| `kimi-k3` | 262K | 4.00 / 20.00 (cache 0.80) | ✓ | `low`,`high`,`max` — **always reasons, default max** |
| `deepseek-v4-1-flash` | 1M | 0.65 / 1.45 (cache 0.13) | ✓ | `none`,`low`,`high`,`xhigh`,`max` (experimental) |
| `gemma4-31b` | 262K | 0.40 / 1.00 | ✓ | `none`…`max` (full scale) |
| `gpt-oss-120b` | 131K | 0.15 / 0.60 | – | `low`,`medium`,`high` only (Harmony) |
| `llama3-3-70b` | 131K | 1.75 / 2.75 | – | not a reasoning model |

Wrong `reasoning_effort` ⇒ **400**. Reasoning trace in `message.reasoning`
(may be null). Reasoning tokens count against `max_tokens`.

## Gotchas (full table: `references/troubleshooting.md`)

- `developer` role ⇒ `400 Unknown message role` → use `system`. `store` param unsupported.
- `429 insufficient_quota` = **lifetime per-key cap** (`max_cost`/token caps), not a
  rate limit — retrying is useless; raise cap or change key. `402` = org balance.
- `AttestationError` → retry once; persistent ⇒ check SDK version, then treat as security event.
- Prompt cache needs ≳ few-thousand-char stable prefix; namespace = API identity +
  `user_cache_secret` (`~/.tinfoil/user_cache_secret` or `TINFOIL_USER_CACHE_SECRET`).

## Pi provider extension (`~/.pi/agent/extensions/tinfoil/index.ts`)

Registers provider `tinfoil` (api `openai-completions`) from live `/v1/models`
(chat-type only), injects `SecureClient.fetch` via a `streamSimple` override,
sets `compat: { supportsDeveloperRole:false, supportsStore:false }`, `maxTokens`
32768 for reasoning models, and maps Pi thinking levels → `reasoning_effort`:

| models | off | minimal | low | medium | high | xhigh | max |
|---|---|---|---|---|---|---|---|
| kimi-k3, glm-5-3(-flash) | low | low | low | low | high | max | max |
| deepseek-v4(-1)-flash, glm-5-2, gemma4-31b | none | minimal | low | medium | high | xhigh | max |
| gpt-oss-120b, gpt-oss-safeguard-120b | low | low | low | medium | high | high | high |

**New reasoning model on Tinfoil ⇒ add it to `thinkingLevelMaps`** or Pi may send a
value the model rejects. Enabled in settings: `tinfoil/glm-5-3`, `tinfoil/kimi-k3`,
`tinfoil/deepseek-v4-1-flash` (glm & deepseek at `xhigh`).

## Reference files (read as needed)

| File | When |
|---|---|
| `references/overview.md` | what Tinfoil is, products, threat model, what they can/can't see |
| `references/api.md` | endpoints, connection modes, reasoning, roles, caching, errors, billing |
| `references/models.md` | full catalog incl. audio/TTS/embeddings/decisions/safety/tools + `reasoning_params` |
| `references/verification.md` | attestation steps, chained enclaves, Sigstore/modelwrap, EHBP, V3 beta |
| `references/sdk-js.md` | `TinfoilAI`, `SecureClient` options, exports, proxy pattern, other SDKs |
| `references/cli.md` | `tinfoil` CLI: http/attestation/pinning/trust policy |
| `references/pi-integration.md` | extension walkthrough + maintenance checklist |
| `references/troubleshooting.md` | symptom → cause → fix |
| `references/sources.md` | provenance, uncovered topics, refresh procedures |
| `references/data/models.json` | raw catalog snapshot |

## Cached raw docs (`references/docs/`)

Verbatim markdown of the 19 docs pages that matter for inference + SDK + verification
(not Containers/Chat/other SDKs). Grep here **before** fetching the web:
`grep -ril "<term>" references/docs/`. File names = doc path with `/` → `__`
(e.g. `sdk__error-handling.md`, `guides__reasoning.md`, `resources__ehbp.md`).
Anything else: fetch `https://docs.tinfoil.sh/<path>.md`; index at `llms.txt`.
Refresh: `bash scripts/sync-docs.sh` (date in `references/docs/.synced`).

## Refresh the catalog

`bash scripts/models.sh > references/data/models.json` (verified connection; prints
nothing secret). Then diff and update `references/models.md` + this table.
