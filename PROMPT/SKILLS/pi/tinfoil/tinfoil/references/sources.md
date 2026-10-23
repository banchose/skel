# Sources & refresh procedures

## Sources used (2026-10-23)

| Source | Used for |
| --- | --- |
| Live `GET /v1/models` via `SecureClient` (JS SDK 1.2.1) | models.md, data/models.json |
| `~/.pi/agent/extensions/tinfoil/index.ts` | pi-integration.md |
| `~/.pi/agent/extensions/tinfoil/node_modules/tinfoil/dist/*.d.ts` | sdk-js.md |
| https://docs.tinfoil.sh/introduction.md | overview |
| https://docs.tinfoil.sh/quickstart.md | connection table, SDK installs |
| https://docs.tinfoil.sh/guides/reasoning.md | reasoning_effort vocabularies |
| https://docs.tinfoil.sh/sdk/javascript-sdk.md | sdk-js |
| https://docs.tinfoil.sh/sdk/error-handling.md | errors, quota codes |
| https://docs.tinfoil.sh/sdk/prompt-caching.md | caching |
| https://docs.tinfoil.sh/local-proxy/cli.md | tinfoil-proxy |
| https://docs.tinfoil.sh/sdk/cli-sdk.md (pasted by user) | cli.md |
| https://docs.tinfoil.sh/verification/verification-in-tinfoil.md | verification |
| https://docs.tinfoil.sh/verification/attestation-architecture.md | supply chain, modelwrap |
| https://docs.tinfoil.sh/guides/proxy-server.md | EHBP proxy pattern |
| https://docs.tinfoil.sh/containers/overview.md | Containers summary |
| https://tinfoil.sh/security-and-privacy-faq | threat model, retention |

Full docs index: https://docs.tinfoil.sh/llms.txt — every page is fetchable as
markdown by appending `.md` to its path.

## Cached raw pages

`references/docs/` holds verbatim markdown for 19 pages (see `scripts/sync-docs.sh`
for the list). Last sync date: `references/docs/.synced`.

## Not yet covered (candidates)

- Containers in depth (`tinfoil-config.yml` reference, volumes, secrets)
- Tinfoil Chat
- `/v1/responses`, `/v1/decisions`, `/v1/realtime` request shapes
- Rate limits (none documented beyond per-key caps)
- Dashboard: org/key management, `max_cost` caps, usage reporting
- Pricing page / plans
- Blog posts: secure prompt caching, modelwrap / proving model identity

## Refresh the model catalog

Run from inside the extension dir so Node can resolve `tinfoil`:

```bash
cd ~/.pi/agent/extensions/tinfoil
cat > _probe-models.mjs <<'EOF'
import { SecureClient } from "tinfoil";
const c = new SecureClient(); await c.ready();
const base = c.getBaseURL().replace(/\/$/, "");
const r = await c.fetch(`${base}/models`, { headers: { Authorization: `Bearer ${process.env.TINFOIL_API_KEY}` }});
console.log(JSON.stringify(await r.json(), null, 2));
EOF
node _probe-models.mjs > /workspace/data/models.json; rm _probe-models.mjs
```

Then diff against the previous snapshot and update models.md + the
`thinkingLevelMaps` in the extension if a new reasoning model appeared.

## Refresh docs

```bash
# any page:
curl -s https://docs.tinfoil.sh/guides/reasoning.md
```
