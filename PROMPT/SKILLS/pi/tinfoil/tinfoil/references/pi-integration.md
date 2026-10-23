# Tinfoil ↔ Pi integration

## Where

- Extension: `~/.pi/agent/extensions/tinfoil/index.ts` (+ `package.json`
  depending on `tinfoil ^1.2.1`; build with `npm ci`).
- Secret: `TINFOIL_API_KEY` in the container env (never in settings).
- Settings (`~/.pi/agent/settings.json`), relevant parts:

```jsonc
"enabledModels": ["tinfoil/kimi-k3", "tinfoil/glm-5-3", "tinfoil/deepseek-v4-1-flash", ...],
"modelThinkingLevels": { "tinfoil/glm-5-3": "xhigh", "tinfoil/deepseek-v4-1-flash": "xhigh" }
```

## What the extension does

1. If `TINFOIL_API_KEY` is unset → does nothing (provider not registered).
2. `new SecureClient()` → `ready()` — attests the router in-process. No local
   proxy needed; plain outbound HTTPS from the container suffices because
   bodies are HPKE-sealed (EHBP).
3. Fetches `/v1/models` with the verified fetch, keeps only entries with
   `type === "chat"` and `/v1/chat/completions` in `endpoints` (drops audio,
   TTS, embeddings, safety, tools, decisions).
4. `pi.registerProvider("tinfoil", …)` with `api: "openai-completions"`, and
   per model:
   - `name`: `Tinfoil <name>`
   - `reasoning` from catalog; `thinkingLevelMap` hard-coded per model (below)
   - `input`: `["text","image"]` if `multimodal`
   - `cost` from `pricing` (`cacheWrite: 0`)
   - `contextWindow` from catalog (fallback 128K)
   - `maxTokens`: 32768 for reasoning models, 8192 otherwise (reasoning tokens
     count against `max_tokens`)
   - `compat: { supportsDeveloperRole: false, supportsStore: false }`
5. Overrides `streamSimple` to call Pi's `openAICompletionsApi().streamSimple`
   with `fetch: client.fetch` — the "ponytail" that injects the verified,
   encrypting fetch. Drop it if Pi ever exposes `fetch` in `ProviderConfig`.

## Thinking-level maps (Pi level → `reasoning_effort`)

Pi levels: `off, minimal, low, medium, high, xhigh, max`.

| Models | off | minimal | low | medium | high | xhigh | max |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `kimi-k3`, `glm-5-3`, `glm-5-3-flash` | low | low | low | low | high | max | max |
| `deepseek-v4-flash`, `deepseek-v4-1-flash`, `glm-5-2`, `gemma4-31b` | none | minimal | low | medium | high | xhigh | max |
| `gpt-oss-120b`, `gpt-oss-safeguard-120b` | low | low | low | medium | high | high | high |

Why: kimi/glm can't turn reasoning off (so `off` → `low`, otherwise they'd
default to `max`); gpt-oss only knows low/medium/high. Models not in the map
get no `thinkingLevelMap` (Pi passes its level through as-is — risk of 400 if
a new reasoning model appears with a restricted vocabulary).

Some IDs in the map (`glm-5-3-flash`, `deepseek-v4-flash`, `glm-5-2`) are no
longer in the live catalog — harmless, kept for forward/backward compat.

## Known quirks encoded in the extension

- `developer` role ⇒ `400 Unknown message role` → `supportsDeveloperRole:false`.
- `store` param unsupported → `supportsStore:false`.
- Base URL from the SDK already ends in `/v1`; trailing slash stripped.

## Model choice notes (fill in from experience)

| Model | Good for | Watch out |
| --- | --- | --- |
| `glm-5-3` | agentic coding, long context (1M) | $5.75/M out; always reasons |
| `deepseek-v4-1-flash` | cheap, 1M ctx, vision, tools | experimental flag |
| `kimi-k3` | strongest reasoning + vision | 20 $/M out, 262K ctx |

_Add observations here: tool-call reliability, latency, failure modes._

## Maintenance checklist

- [ ] When Tinfoil adds a reasoning model, add it to `thinkingLevelMaps` with
      its accepted vocabulary (check `/v1/models` → `reasoning_params` and
      https://docs.tinfoil.sh/guides/reasoning.md).
- [ ] Bump `tinfoil` npm package periodically (newer SDKs pin newer
      measurements / refuse vulnerable firmware). `cd ~/.pi/agent/extensions/tinfoil && npm update tinfoil`.
- [ ] Re-snapshot `data/models.json` (see sources.md) and update models.md.
