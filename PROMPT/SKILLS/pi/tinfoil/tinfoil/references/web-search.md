# Web search

Sources: `docs/guides__web-search.md`, `docs/guides__mcp-websearch.md`
(cached 2026-10-23). Backend provider is **Exa** (Zero Data Retention) — the
enclave holds a single shared Exa key, so Exa sees only the enclave's IP, never
the user. Tinfoil never sees queries in plaintext. Fee: **$0.05 per request**
(`websearch` entry in `/v1/models`), charged once per chat request that
performed ≥1 search/fetch, regardless of how many calls.

## Flavor 1 — built into chat (model does the tool loop)

Add one field; response comes back with citations, no tool handling needed.

```jsonc
// POST /v1/chat/completions
{ "model": "glm-5-3", "messages": [...],
  "web_search_options": { /* tuning, optional */ },
  "pii_check_options": {},                // optional: mask PII in queries before Exa
  "prompt_injection_check_options": {} }  // optional: drop injected results/pages

// POST /v1/responses  (recommended — native web_search_call items + streaming events)
{ "model": "glm-5-3", "input": "...",
  "tools": [{ "type": "web_search", /* same tuning fields */ }],
  "include": ["web_search_call.action.sources"] }
```

Tuning fields (`web_search_options.<f>` or `tools[].<f>`):

| Field | Values / notes |
| --- | --- |
| `search_context_size` | `low` \| `medium` (default) \| `high` |
| `user_location` | `{type:"approximate", approximate:{country:"US"}}` — only country honoured |
| `filters.allowed_domains` / `filters.excluded_domains` | hostnames |
| `content_mode` | `highlights` \| `text` |
| `max_content_chars` | per-result budget |
| `category` | e.g. `news`, `research paper` |
| `start_published_date` / `end_published_date` | `YYYY-MM-DD` or RFC 3339 |
| `max_age_hours` | only results from last N hours |
| `external_web_access` | `false` ⇒ cached content only, no page opening |

Citations: chat completions → `message.annotations[]` / streaming
`delta.annotations[]` with `type: "url_citation"` `{title,url}`; Responses →
`web_search_call` output items + `response.output_text.annotation.added`.

Usage header (via proxy, `X-Tinfoil-Request-Usage-Metrics: true`):
`web_search_calls=N` present only if search ran; `cost_usd` includes fee.

## Flavor 2 — standalone MCP server (you run the tool loop)

| Item | Value |
| --- | --- |
| MCP endpoint | `POST https://websearch.tinfoil.sh/mcp` (Streamable HTTP) |
| Health | `GET https://websearch.tinfoil.sh/health` |
| Auth | `Authorization: Bearer $TINFOIL_API_KEY` |
| Repo | `tinfoilsh/confidential-websearch` |
| Attestation | it's an enclave — use a Tinfoil SDK/CLI client to verify + pin |

Tools (`tools/list` works):

**`search`** — `query` (≤~400 chars, required), `max_results` (1–30, default 8),
`content_mode` (`highlights`|`text`), `max_content_chars` (700),
`user_location_country`, `allowed_domains`, `excluded_domains`, `category`
(`company`,`people`,`research paper`,`news`,`personal site`,`financial report`;
`company`/`people` incompatible with date filters + `excluded_domains`),
`start_published_date`, `end_published_date`, `max_age_hours` (`0` = force
livecrawl, `-1` = cache only).
Returns `results[{title,url,content,favicon?,published_date?,author?}]` plus
PII metadata: `pii_checked`, `pii_masked`, `redacted_query`, `pii_redactions[{type,start,end}]`
(code-point offsets), `pii_filter_requests`. PII-check failure ⇒ MCP
`isError: true`, query not sent to Exa.

**`fetch`** — `urls[]` (≤20), optional `allowed_domains`. Returns `pages[{url,content}]`
and `results[{url,status: completed|failed, content|error}]`. No PII masking on URLs.

Safety filters have server defaults; override per request with headers (see
`docs/guides__mcp-websearch.md` § "Per-request safety headers").

## Relation to the Pi setup

**Wired in (2026-10-23):** `mcp-adapter.json` entry `tinfoil-websearch` →
`https://websearch.tinfoil.sh/mcp`, `Authorization: Bearer ${TINFOIL_API_KEY}`,
`directTools: true`. Exposes `tinfoil-websearch_search` / `tinfoil-websearch_fetch`.
Observed: the server runs the PII filter by default (`pii_checked: true,
pii_filter_requests: 1`), i.e. +$0.005 privacy-filter fee per search on top of
$0.05. Plain HTTPS through the adapter — no attestation, but no account linkage.
Prefer these over `exa_*` when the goal is to avoid profiling.


Pi's own `exa_web_search_exa` tool talks to Exa **directly** (no enclave, your
own Exa key). Tinfoil's version routes the same provider through an attested
enclave with a shared key — the privacy gain is that neither Tinfoil nor Exa
can tie queries to you. Not wired into the Pi extension today; it would be a
separate custom tool or MCP server entry pointing at `websearch.tinfoil.sh/mcp`.
