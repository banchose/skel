# Tinfoil — overview

## One-liner

Tinfoil runs open-weight AI models inside hardware secure enclaves (confidential
VMs) so that **neither Tinfoil nor its cloud providers can read prompts or
completions**. Clients verify this per connection via remote attestation tied to
open-source code and public transparency logs.

## Products

| Product | What | Endpoint / entry |
| --- | --- | --- |
| **Tinfoil Inference** | OpenAI-compatible API over open models (chat, vision, audio, TTS, embeddings, decisions, safety) | `https://inference.tinfoil.sh/v1` (router) |
| **Tinfoil Chat** | Consumer chat app (web + iOS) with E2E-encrypted sync | chat.tinfoil.sh |
| **Tinfoil Containers** | Run your own Docker image inside an AMD SEV-SNP / Intel TDX enclave (GPU on request) | dashboard + `tinfoil-config.yml` in a public repo |
| **Tinfoil Proxy** | Local `http://127.0.0.1:3301/v1` that does attestation for apps that can't use an SDK (CLI binary or macOS menu-bar app) | `tinfoil-proxy` |
| **SDKs** | Python, JavaScript/TypeScript, Go, Rust, Swift, CLI — all wrap the OpenAI client and add verification | see [sdk-js.md](sdk-js.md) |

## Architecture in brief

```
client (SDK)  --verifies-->  router enclave (inference.tinfoil.sh / router-N.tinfoil.sh)
                                   |--verifies-->  model enclave (vLLM + weights)
                                   |--verifies-->  tool enclaves (web search, doc convert, PII filter)
```

- The SDK verifies **only the router**; the router verifies every model/tool
  enclave before forwarding ("chained attestation"). The trusted repo for each
  model is compiled into the router's measured code.
- Request bodies are encrypted with **EHBP** (HPKE, RFC 9180) straight to the
  attested enclave key — so an intermediate proxy (yours or Cloudflare) sees
  headers only, never bodies.
- Hardware: AMD SEV-SNP, Intel TDX CPUs; NVIDIA Hopper/Blackwell GPUs in
  confidential-compute mode. Inference server: vLLM.
- Model weights are not CPU-measured, so they're packaged with **modelwrap**
  (dm-verity root hash pinned in `tinfoil-config.yml`).

## What Tinfoil can / can't see

**Sees:** account + billing data, network metadata (IPs, timing, byte counts —
streaming responses are padded), per-request billing metadata (input/output
token counts, model, timestamp), Chat-only safeguard violation flags.

**Cannot see (by construction):** prompts, completions, uploaded files,
embeddings, tool-call payloads, request/response bodies, error traces with user
content. API traffic is **not** moderated or classified. Nothing is retained
after the response except prompt-cache KV state in enclave GPU memory. No
training on your data (also contractually in the DPA).

## Threat model (short)

Protects against: Tinfoil staff, legal compulsion (nothing to hand over),
infra providers, compromised hypervisor/root on host, silent model/code swaps,
host MITM.

Does **not** protect against: network metadata leakage, hardware vulns in
SEV-SNP/TDX (physical attacks exist, e.g. tee.fail), side channels, leaked API
keys, compromised client device, denial of service.

## Links

- Site: https://tinfoil.sh · Docs: https://docs.tinfoil.sh (every page also at
  `<path>.md`; index at https://docs.tinfoil.sh/llms.txt)
- GitHub: https://github.com/tinfoilsh (router repo:
  `tinfoilsh/confidential-model-router`)
- Security FAQ: https://tinfoil.sh/security-and-privacy-faq
