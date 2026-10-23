# `tinfoil` JavaScript/TypeScript SDK

Installed in `~/.pi/agent/extensions/tinfoil/node_modules/tinfoil` — **v1.2.1**
(2026-10-23). Requires Node 20+. `npm install tinfoil`.

## Two entry points

### `TinfoilAI` — drop-in OpenAI client

```ts
import { TinfoilAI } from "tinfoil";
const client = new TinfoilAI({ apiKey: process.env.TINFOIL_API_KEY }); // env var also auto-read
const r = await client.chat.completions.create({ model: "glm-5-3", messages: [...] });
```

Extends the `openai` client — same method surface. **Do not set `baseURL`**
unless routing through your own proxy. `dangerouslyAllowBrowser: true` for
browser use; `await client.ready()` to pre-verify.

### `SecureClient` — low-level verified `fetch`

```ts
import { SecureClient } from "tinfoil";
const sc = new SecureClient();          // options below
await sc.ready();                       // attestation done here
sc.getBaseURL();                        // e.g. https://router-0.tinfoil.sh/v1
await sc.fetch(url, init);              // bodies HPKE-sealed, enclave verified
```

This is what the Pi extension uses: it hands `sc.fetch` to Pi's generic
OpenAI-completions driver.

`SecureClientOptions`:

| Option | Purpose | Default |
| --- | --- | --- |
| `baseURL` | your proxy URL (EHBP) or custom path on enclave origin (TLS) | router |
| `enclaveURL` | explicit enclave, overrides attestation-bundle domain | auto |
| `configRepo` | GitHub repo whose releases are trusted | `tinfoilsh/confidential-model-router` |
| `transport` | `'ehbp'` (default, proxy-safe) or `'tls'` (cert pinning, direct only) | `ehbp` |
| `attestationBundleURL` | where to fetch bundle | auto |
| `userCacheSecret` | prompt-cache namespace secret | `TINFOIL_USER_CACHE_SECRET` env → `~/.tinfoil/user_cache_secret` → in-memory |

## Other exports (`dist/index.d.ts`)

- Errors: `TinfoilError`, `ConfigurationError`, `AttestationError` (+ all
  OpenAI errors re-exported: `AuthenticationError`, `RateLimitError`,
  `BadRequestError`, …). `FetchError` is **not** exported — check
  `err.name === "FetchError"`.
- `Verifier`, `assembleAttestationBundle`, `fetchRouter`,
  `fetchAttestationBundle` and the `VerificationDocument` /
  `AttestationMeasurement` types — for displaying/auditing verification state.
- `createTinfoilAI` — Vercel AI SDK provider.
- EHBP session recovery: `serializeSessionRecoveryToken`,
  `deserializeSessionRecoveryToken`, `decryptResponseWithToken` (for backend
  proxies that must resume a client's encrypted stream).
- Browser build (`index.browser.js`) with pinned-TLS fetch and pinned
  WebSocket helpers for `/v1/realtime`.

## Proxy pattern (keep key server-side)

Client SDK encrypts bodies to the enclave → your backend adds
`Authorization` header, user auth, rate limits → forwards to Tinfoil. Backend
sees headers only. Use HTTPS; allowlist enclave destinations; never ship
`TINFOIL_API_KEY` to a browser.
Guide: https://docs.tinfoil.sh/guides/proxy-server.md

## Other SDKs (for reference)

| Lang | Install | Notes |
| --- | --- | --- |
| Python | `pip install tinfoil` → `TinfoilAI` | wraps `openai` |
| Go | `go get github.com/tinfoilsh/tinfoil-go` | wraps `openai-go/v3`; V3 attestation (beta) |
| Rust | `cargo add tinfoil --git https://github.com/tinfoilsh/tinfoil-rs` | wraps `async-openai` |
| Swift | `tinfoilsh/tinfoil-swift` | V3 (beta) |
| CLI | `curl -fsSL https://github.com/tinfoilsh/tinfoil-cli/raw/main/install.sh \| sh` | `tinfoil http post … -e inference.tinfoil.sh -r tinfoilsh/confidential-model-router`; V3 (beta) |
| Proxy | `tinfoilsh/tinfoil-proxy` (binary, Docker `ghcr.io/tinfoilsh/tinfoil-proxy`) | serves `http://127.0.0.1:3301/v1`; flags `-p -b -e -r --user-cache-secret` |
