> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# MCP web-search server

> Call Tinfoil's confidential websearch MCP server directly over attested HTTP.

## Overview

The [`confidential-websearch`](https://github.com/tinfoilsh/confidential-websearch) MCP server runs inside a Tinfoil secure enclave and exposes two tools: `search` (web search via [Exa](https://exa.ai), a Zero Data Retention provider) and `fetch` (page text retrieval via Exa Contents). The enclave sends queries or URLs to Exa over TLS and returns the results to the caller through the verified transport.

Use this guide to call the web-search tools from your own agent runtime or an MCP-compatible client. For web search built into a chat completion, follow the [Web search guide](/guides/web-search.md). It uses the same server through `web_search_options` and the `web_search` Responses tool.

Optional safety filters run inside secure enclaves:

* **PII filter** removes detected sensitive identifiers from outgoing search queries before they reach Exa. Search continues with the remaining query.
* **Prompt-injection filter** drops search results and fetched pages that contain instructions aimed at hijacking a downstream model.

Both filters have server-configured defaults that callers can override with [per-request safety headers](#per-request-safety-headers).

## Endpoint and transport

| Item | Value |
| - | - |
| Production host | `websearch.tinfoil.sh` |
| MCP endpoint | `POST https://websearch.tinfoil.sh/mcp` |
| Health check | `GET https://websearch.tinfoil.sh/health` |
| Transport | MCP Streamable HTTP |
| Source repo | [`tinfoilsh/confidential-websearch`](https://github.com/tinfoilsh/confidential-websearch) |

Any MCP-compliant client can introspect the tool surface by calling `tools/list` on the endpoint.

Raw HTTP clients must accept both `application/json` and `text/event-stream` responses. An MCP Streamable HTTP transport handles this framing and returns the tool result; an SSE response must not be parsed as a single JSON document.

## Authentication

Send your Tinfoil API key as a bearer token:

```
Authorization: Bearer $TINFOIL_API_KEY
```

This is an attested enclave. For connection-time trust guarantees, connect through a client that verifies the enclave's attestation and pins its TLS certificate or HPKE key. See [Calling from a Tinfoil SDK](#calling-from-a-tinfoil-sdk) below.

## Tools

### `search`

Run a web search and return ranked results with titles, URLs, snippets, and publication dates.

#### Arguments

| Name | Type | Required | Default | Description |
| - | - | - | - | - |
| `query` | string | yes | - | Natural language search query. Max \~400 characters. |
| `max_results` | int | no | `8` | Number of results to return, from 1 to 30. `0` uses the default; values above 30 are rejected. |
| `content_mode` | string | no | `highlights` | `highlights` returns key excerpts relevant to the query. `text` returns the full page text as markdown. |
| `max_content_chars` | int | no | `700` | Per-result character budget for the snippet or text returned in each hit. |
| `user_location_country` | string | no | - | ISO 3166-1 alpha-2 country code (e.g. `US`, `GB`, `DE`) used to bias results toward that locale. |
| `allowed_domains` | string\[] | no | - | Only return results whose host matches one of these domains. |
| `excluded_domains` | string\[] | no | - | Drop results from these domains. |
| `category` | string | no | - | Restrict to one of: `company`, `people`, `research paper`, `news`, `personal site`, `financial report`. `company` and `people` are incompatible with date filters and `excluded_domains`. |
| `start_published_date` | string | no | - | ISO-8601 date. Only include results published at or after this instant. |
| `end_published_date` | string | no | - | ISO-8601 date. Only include results published at or before this instant. |
| `max_age_hours` | int | no | - | Cache freshness control. `0` forces a livecrawl on every result (freshest, slowest). `-1` disables livecrawl (cache-only, fastest). Omit for the upstream default. |

#### Response

The search payload is returned in MCP `result.structuredContent` and as serialized JSON in a text block under `result.content`. For example, if the filter detects the personal email in `john@example.com hiking trails`:

```json theme={"dark"}
{
  "results": [
    {
      "title": "string",
      "url": "string",
      "content": "string",
      "favicon": "string (optional)",
      "published_date": "string (optional, ISO-8601)",
      "author": "string (optional)"
    }
  ],
  "pii_checked": true,
  "pii_masked": true,
  "redacted_query": "hiking trails",
  "pii_redactions": [
    { "type": "private_email", "start": 0, "end": 16 }
  ]
}
```

| Field | Meaning |
| - | - |
| `pii_checked` | `true` when the PII check completed for this query. `false` means it did not run, not that the query contains no PII. |
| `pii_masked` | `true` when at least one sensitive span was removed. This does not mean the search was blocked. |
| `redacted_query` | The query after filtering, present only when `pii_checked` is `true`. If nothing was removed, this matches the original query. |
| `pii_redactions` | Removed spans, ordered by position in the original query. Each contains a category (`type`) and zero-based Unicode code point offsets (`start` inclusive, `end` exclusive). Empty when nothing was removed. |
| `pii_filter_requests` | Number of billable privacy-filter requests. If absent or `null`, billing is unknown. |

The span list does not repeat sensitive values. Callers can use the offsets to identify removed text in their own original query. Offsets exclude adjacent whitespace removed during cleanup and are not UTF-8 byte or JavaScript UTF-16 code unit offsets.

Masking follows the model's detected span boundaries, which may cover only part of a sensitive value. Neither `pii_checked: true` nor `pii_masked: true` guarantees that the remaining query is free of PII.

If filtering leaves an empty or whitespace-only query, the server skips Exa and returns an empty `results` array with the PII metadata. If the PII check fails, the server does not send the query to Exa and returns an MCP tool error (`isError: true`), not a successful checked result.

### `fetch`

Fetch one or more web pages via Exa Contents and return their text. Use this after `search` when you need the full page beyond the returned snippet.

#### Arguments

| Name | Type | Required | Default | Description |
| - | - | - | - | - |
| `urls` | string\[] | yes | - | One or more HTTP/HTTPS URLs. Capped at 20 per request. |
| `allowed_domains` | string\[] | no | - | If set, reject any URL whose host does not match a listed domain or its subdomains before sending it to Exa. |

Use public HTTP/HTTPS URLs. PII masking does not apply to fetch URLs, so do not include sensitive values in them.

#### Response

`results` includes both completed and failed fetches. Match entries by `url`: URLs rejected by `allowed_domains` appear after the fetched results. `pages` contains successful pages with non-empty content and may be omitted when none succeeded.

```json theme={"dark"}
{
  "pages": [
    { "url": "string", "content": "string (page text)" }
  ],
  "results": [
    {
      "url": "string",
      "status": "completed | failed",
      "content": "string (present when status=completed)",
      "error": "string (present when status=failed)"
    }
  ]
}
```

## Per-request safety headers

The server's safety filters have defaults, but an integrator can override them on a single request by forwarding either header on the `POST /mcp` call. Missing, empty, or unparseable values fall back to the server default, so a malformed header cannot silently weaken filtering.

| Header | Values | Effect |
| - | - | - |
| `X-Tinfoil-Tool-PII-Check` | `true`, `false`, `1`, `0` | Override PII masking on outgoing search queries for this request only. |
| `X-Tinfoil-Tool-Injection-Check` | `true`, `false`, `1`, `0` | Override the prompt-injection filter on search results and fetched pages for this request only. |

`X-Tinfoil-Tool-PII-Check: true` runs the check when you call the MCP `search` tool directly. Send it on the HTTP request carrying `tools/call`, not only on MCP initialization. A successful search is expected even when PII was masked. Inspect `result.structuredContent.pii_checked` and `pii_redactions` to see whether the check ran and what it removed.

Names alone are allowed. Personal emails are removed when detected; invented names or addresses do not guarantee a particular model classification. The PII filter applies to the search `query`, not to `fetch` URLs or returned page content.

See [PII protection](/guides/web-search.md#pii-protection) and [Prompt-injection protection](/guides/web-search.md#prompt-injection-protection) in the Web search guide for the filtering policies.

## Calling from a Tinfoil SDK

Because the websearch server is an attested enclave, verify its attestation before trusting traffic to it. Each Tinfoil SDK provides verified HTTP access: it checks the enclave against the signed release from `tinfoilsh/confidential-websearch` and binds requests to the attested TLS or HPKE key.

The example below pairs `tinfoil-js` with the TypeScript MCP SDK to call `search` with PII masking enabled. Resolve `/mcp` from the origin, not by appending it to the SDK's inference base URL, which includes `/v1/`.

```typescript theme={"dark"}
import { SecureClient } from "tinfoil";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";

const secure = new SecureClient({
  enclaveURL: "https://websearch.tinfoil.sh",
  configRepo: "tinfoilsh/confidential-websearch",
});
await secure.ready();

const transport = new StreamableHTTPClientTransport(
  new URL("/mcp", secure.getBaseURL()),
  {
    fetch: secure.fetch,
    requestInit: {
      headers: {
        Authorization: `Bearer ${process.env.TINFOIL_API_KEY}`,
        "X-Tinfoil-Tool-PII-Check": "true",
      },
    },
  },
);

const client = new Client({ name: "websearch-example", version: "0.1.0" });
await client.connect(transport);

const result = await client.callTool({
  name: "search",
  arguments: {
    query: "confidential computing attestation 2026",
    max_results: 5,
  },
});

console.log(result);
await client.close();
```

If verification fails, `ready()` rejects before any MCP request is sent. See the [JavaScript SDK guide](/sdk/javascript-sdk.md) for transport-mode options (EHBP vs. TLS pinning) and proxying.

For the other SDKs, use the following verified HTTP entry points to send MCP requests to `https://websearch.tinfoil.sh/mcp`. Set the bearer token and safety headers on each request. Hostname parameters use `websearch.tinfoil.sh` without a scheme; URL parameters use `https://websearch.tinfoil.sh`.

| SDK | Configure the enclave and repository | Verified HTTP access |
| - | - | - |
| [Python](/sdk/python-sdk.md) | `NewSecureClient(enclave=host, repo=repo)` | `client.post(...)` |
| [Go](/sdk/go-sdk.md) | `NewClientWithOptions(WithEnclave(host), WithRepo(repo))` | `client.HTTPClient().Do(req)` |
| [Rust](/sdk/rust-sdk.md) | `SecureClient::new(host, repo, api_key)` | Call `verify().await?`, then use `http_client()?.post(...)`. |
| [Swift](/sdk/swift-sdk.md) | `SecureClient(githubRepo: repo, enclaveURL: url)` | Call `verify()`, then `post(url:headers:body:)`, both with `try await`. |

In each row, `repo` is `tinfoilsh/confidential-websearch`. These HTTP clients handle connection-time verification, not MCP message framing; use an MCP transport adapter or handle the JSON-RPC and SSE envelopes before reading `result.structuredContent`.

## Limits and defaults

| Item | Value |
| - | - |
| `search.max_results` default | 8 |
| `search.max_results` cap | 30 |
| `search.max_content_chars` default | 700 |
| `fetch.urls` per-call cap | 20 |
| Exa Contents batch request timeout | 30s |
| Fetched page text truncation | 50,000 Unicode code points, followed by a truncation marker |

## See also

* [Web search guide](/guides/web-search.md): the higher-level wrapper that drives this server for you on `/v1/chat/completions` and `/v1/responses`.
* [`tinfoilsh/confidential-websearch`](https://github.com/tinfoilsh/confidential-websearch): source and release history for the MCP server itself.
* [JavaScript SDK](/sdk/javascript-sdk.md): the attested `SecureClient` used in the example above.


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.