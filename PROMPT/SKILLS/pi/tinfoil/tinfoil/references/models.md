# Tinfoil model catalog

Snapshot of `GET /v1/models` on **2026-10-23** via the JS SDK (verified
connection). Raw JSON: [`data/models.json`](data/models.json). Prices are USD
per 1M tokens unless noted. `intelligence` is Tinfoil's own score (higher =
better), keyed by effort level.

## Chat models (`type: chat`, `/v1/chat/completions` + `/v1/responses`)

| ID | Name | Context | Input $ | Output $ | Cached in $ | Vision | Tools | Reasoning | Intelligence | Notes |
| --- | --- | ---: | ---: | ---: | ---: | :-: | :-: | :-: | --- | --- |
| `glm-5-3` | GLM-5.3 (Z.ai) | 1,048,576 | 1.80 | 5.75 | 0.45 | – | ✓ | always (`low`/`high`/`max`, default max) | low 39 / med 42 / high 45 | "flagship for agentic coding and long-horizon tasks" |
| `kimi-k3` | Kimi K3 (Moonshot) | 262,144 | 4.00 | 20.00 | 0.80 | ✓ | ✓ | always (`low`/`high`/`max`, default max) | on 45 | hybrid attention, multimodal MoE; priciest |
| `deepseek-v4-1-flash` | DeepSeek V4.1 Flash | 1,048,576 | 0.65 | 1.45 | 0.13 | ✓ | ✓ | `none`…`max` | off 22 / low 31 / med 36 / high 39 | **experimental**; Engram memory, speculative decoding |
| `gemma4-31b` | Gemma 4 31B (Google) | 262,144 | 0.40 | 1.00 | – | ✓ | ✓ | `none`…`max` (`enable_thinking` toggle) | off 14 / on 15 | |
| `gpt-oss-120b` | GPT-OSS 120B | 131,072 | 0.15 | 0.60 | – | – | ✓ | `low`/`medium`/`high` only | 10 / 11 / 12 | cheapest reasoning model; Harmony format |
| `llama3-3-70b` | Llama 3.3 70B | 131,072 | 1.75 | 2.75 | – | – | ✓ | none | off 8 | chat/completions only, no `/v1/responses` |

Enabled in Pi today: `glm-5-3`, `kimi-k3`, `deepseek-v4-1-flash` (see
[pi-integration.md](pi-integration.md)).

### Quick cost comparison (1M in + 200K out, no cache)

| Model | ≈ $ |
| --- | ---: |
| gpt-oss-120b | 0.27 |
| gemma4-31b | 0.60 |
| deepseek-v4-1-flash | 0.94 |
| llama3-3-70b | 2.30 |
| glm-5-3 | 2.95 |
| kimi-k3 | 8.00 |

## Weights, quantization, config repos (from docs `models/chat`)

All six support structured outputs (`response_format`). The config repo is what the
router's attestation chain pins for that model; the HF repo is what modelwrap packages.

| ID | Params | Quantization | HF weights | Config repo |
| --- | --- | --- | --- | --- |
| `kimi-k3` | 2.8T total / 104B active | MXFP4 weights, MXFP8 activations (native) | `moonshotai/Kimi-K3` | `tinfoilsh/confidential-kimi-k3` |
| `glm-5-3` | 743B / 39B active | NVFP4 MoE experts (Inferact); attention/shared/dense in BF16 | `Inferact/GLM-5.3-NVFP4` | `tinfoilsh/confidential-glm5-3-nvfp4` |
| `deepseek-v4-1-flash` | 552B MoE (6/384 routed + 1 shared active); Engram memory | FP8 attention / FP4 experts (native) | `deepseek-ai/DeepSeek-V4.1-Flash` | `tinfoilsh/confidential-deepseek-v4-1-flash` |
| `gemma4-31b` | 31B dense | none (BF16) | `google/gemma-4-31B-it` | `tinfoilsh/confidential-gemma4-31b` |
| `gpt-oss-120b` | 117B / 5.1B active | MXFP4 (native) | `openai/gpt-oss-120b` | `tinfoilsh/confidential-gpt-oss-120b` |
| `llama3-3-70b` | 70B dense | FP8 weights + dynamic FP8 activations | `RedHatAI/Llama-3.3-70B-Instruct-FP8-dynamic` | `tinfoilsh/confidential-llama3-3-70b` |

Note: `glm-5-3` and `llama3-3-70b` are served from *third-party* quantized
releases (Inferact, RedHatAI), not the original lab's weights.

## Other models

| ID | Type | Endpoint(s) | Pricing | Notes |
| --- | --- | --- | --- | --- |
| `gpt-oss-safeguard-120b` | safety | chat/completions, responses | 0.15 in / 0.60 out | content classification, `low/medium/high` effort |
| `pii-filter` | safety | `/redact` | $0.005 / request | PII span detection + redaction, 8K ctx |
| `nomic-embed-text` | embedding | `/v1/embeddings` | 0.05 in | 8K ctx |
| `doc-upload` | document | `/v1/convert/file` | $0.05 / request | document → text conversion |
| `websearch` | tool | chat/completions, responses; MCP at `websearch.tinfoil.sh/mcp` | $0.05 / request | private web search (Exa, ZDR, enclave-held key) — see web-search.md |
| `voxtral-small-24b` | audio | transcriptions, translations, chat/completions | 0.20 in / 0.60 out | Mistral Small 3.1-based; 32K ctx |
| `whisper-large-v3-turbo` | audio | `/v1/audio/transcriptions` | $0.01 / request | |
| `voxtral-mini-4b-realtime` | audio | `/v1/realtime` (WS) | $0.002 / request | streaming STT |
| `qwen3-tts` | tts | `/v1/audio/speech` | $0.01 / request | Qwen3-TTS 1.7B |
| `voxtral-tts` | tts | `/v1/audio/speech` | $0.002 / request | |
| `decision-small` / `-medium` / `-large` | decision | `/v1/decisions` | 0.02 / 0.06 / 0.40 in | experimental; classification / rubric scoring with calibrated probabilities; 32K ctx |

## `reasoning_params` field (how the router maps effort)

```jsonc
// deepseek-v4-1-flash
"effort_map": { "low": "low", "medium": "high", "high": "xhigh" },
"params": { "/v1/chat/completions": {
  "enable":  { "chat_template_kwargs": { "reasoning_effort": "$EFFORT", "thinking": true } },
  "disable": { "chat_template_kwargs": { "thinking": false } } } }

// glm-5-3  — enable only, no disable (always reasons)
"effort_map": { "low": "low", "medium": "high", "high": "max" }

// gemma4-31b — binary toggle via enable_thinking
// gpt-oss-120b — passes reasoning_effort top-level (chat) / reasoning.effort (responses)
// kimi-k3 — no reasoning_params published; use reasoning_effort low/high/max
```

## Refreshing this file

See [sources.md](sources.md) → "Refresh the model catalog".
