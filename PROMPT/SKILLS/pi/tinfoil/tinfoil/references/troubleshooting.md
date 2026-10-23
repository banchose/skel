# Troubleshooting / gotchas

| Symptom | Cause | Fix |
| --- | --- | --- |
| `400 Unknown message role` | `developer` role sent (OpenAI-style reasoning default) | use `system`; Pi ext sets `supportsDeveloperRole:false` |
| `400` on `reasoning_effort` | value not in model's vocabulary (e.g. `max` to gpt-oss, `medium` to glm/kimi) | see api.md table; Pi ext maps levels |
| kimi-k3 / glm-5-3 slow + expensive by default | they default to `reasoning_effort: max` when omitted | always send an effort; Pi maps `off`→`low` |
| `429 insufficient_quota` | **lifetime** per-key cap (`max_cost` / token caps) — not a rate limit | raise/clear cap in dashboard or use another key; retrying is pointless |
| `402 insufficient_quota` | org balance / subscription | billing |
| `AttestationError` | verification failed | retry once; persistent ⇒ check SDK version, then treat as security event |
| `FetchError` (name only, not exported) | couldn't fetch attestation bundle / Sigstore | network; inspect `err.cause` (`501` = unsupported enclave) |
| Truncated answers from reasoning models | reasoning tokens eat `max_tokens` | raise budget (Pi ext uses 32768 for reasoning models) |
| `cached_tokens` lower than expected / zero | prompt < few-thousand chars, prefix changed, chunk alignment, eviction, or different `user_cache_secret` | stable prefix first; one secret per user/session |
| Script importing `tinfoil` fails with `ERR_MODULE_NOT_FOUND` | Node resolves from the script's dir, not cwd | run scripts from inside `~/.pi/agent/extensions/tinfoil/` |
| `tinfoil` CLI not found | not installed in this container | use the JS SDK via the extension's `node_modules`, or install CLI (docs quickstart) |
| Requests through a corporate/Cloudflare proxy fail in `tls` transport | TLS pinning needs a direct connection | use default `ehbp` transport |
| SecureClient refuses to connect to a Container | instance is in debug mode (not attested) | deploy a non-debug instance |

## Observed facts (dated)

- 2026-10-23: `SecureClient.getBaseURL()` → `https://router-0.tinfoil.sh/v1` on one run,
  `https://inference.tinfoil.sh/v1` on the next (per-connection router selection);
  `/v1/models` returned 19 entries, 6 chat models.
