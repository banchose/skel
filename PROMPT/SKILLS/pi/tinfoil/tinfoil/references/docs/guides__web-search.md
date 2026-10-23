> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# Web search

> Let AI models search the web with optional PII and prompt-injection protection.

## Overview

Tinfoil's web search lets models augment their answers with fresh information from the web. Search runs inside a secure enclave and talks directly to [Exa](https://exa.ai), a search provider with Zero Data Retention (ZDR). That gives you:

* **Query privacy**: queries go from the enclave to Exa over TLS. Tinfoil never sees the query contents in plaintext.
* **User anonymity from the search provider**: all users share a single enclave-held API key, so Exa only sees the enclave's IP address.
* **Legal protections**: Exa's ZDR agreement ensures queries are never written to persistent storage or sent to external subprocessors.
* **Optional PII protection**: a privacy filter can remove detected sensitive information from outgoing queries before they are sent to Exa.
* **Optional prompt-injection protection**: a safeguard model can scan search results and fetched pages for prompt-injection attempts and filter them out before the model sees them.

You turn web search on per request. The response you get back is a normal chat completion (or Responses API response) with citations already attached - you do not need to handle any tool calls yourself.

> [!NOTE]
>
> Read our [blog post on private AI web search](https://tinfoil.sh/blog/2026-01-22-private-ai-web-search) for background.

## Choosing an API surface

You can enable web search on either of Tinfoil's OpenAI-compatible endpoints:

* **`/v1/responses`** (recommended): search progress and citations are surfaced through OpenAI's native `web_search_call` items and `response.web_search_call.*` / `response.output_text.annotation.added` streaming events.
* **`/v1/chat/completions`** (supported for compatibility): citations are surfaced on the final message and on `delta.annotations` in streaming. The OpenAI Chat Completions spec has no native live-progress event for web search, so if you want a live progress UI there, see [Streaming progress markers](#optional-streaming-progress-markers-chat-completions).

To manage the tool loop yourself, call the underlying [MCP web-search server](/guides/mcp-websearch.md) directly instead.

## Quick start

Enable web search by adding `web_search_options` to a Chat Completions request, or a `web_search` tool to a Responses request. Optionally add `pii_check_options` and/or `prompt_injection_check_options` to enable the safety filters.

### Chat Completions (`/v1/chat/completions`)

```typescript JavaScript theme={"dark"}
import { TinfoilAI } from 'tinfoil';

const client = new TinfoilAI({
  apiKey: process.env.TINFOIL_API_KEY,
});

const stream = await client.chat.completions.create({
  model: '<MODEL_NAME>',
  messages: [
    { role: 'user', content: 'What are the latest developments in quantum computing?' },
  ],
  web_search_options: {},
  pii_check_options: {},              // Optional: mask PII in search queries
  prompt_injection_check_options: {}, // Optional: filter injected instructions from results
  stream: true,
});

for await (const chunk of stream) {
  const delta = chunk.choices?.[0]?.delta;

  // Citations arrive as annotation deltas alongside content.
  if (delta?.annotations) {
    for (const annotation of delta.annotations) {
      if (annotation.type === 'url_citation') {
        const { title, url } = annotation.url_citation;
        console.log(`\nCitation: ${title} - ${url}`);
      }
    }
  }

  if (delta?.content) {
    process.stdout.write(delta.content);
  }
}
```

```python Python theme={"dark"}
from tinfoil import TinfoilAI

client = TinfoilAI(api_key="<YOUR_API_KEY>")

stream = client.chat.completions.create(
    model="<MODEL_NAME>",
    messages=[
        {"role": "user", "content": "What are the latest developments in quantum computing?"},
    ],
    extra_body={
        "web_search_options": {},
        "pii_check_options": {},              # Optional
        "prompt_injection_check_options": {}, # Optional
    },
    stream=True,
)

for chunk in stream:
    if not chunk.choices:
        continue
    delta = chunk.choices[0].delta

    if getattr(delta, "annotations", None):
        for annotation in delta.annotations:
            if annotation.type == "url_citation":
                cite = annotation.url_citation
                print(f"\nCitation: {cite.title} - {cite.url}")

    if delta.content:
        print(delta.content, end="", flush=True)
```

```go Go theme={"dark"}
package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/openai/openai-go/v3"
	"github.com/openai/openai-go/v3/option"
	"github.com/tinfoilsh/tinfoil-go"
)

func main() {
	client, err := tinfoil.NewClient(
		option.WithAPIKey(os.Getenv("TINFOIL_API_KEY")),
	)
	if err != nil {
		log.Fatal(err)
	}

	stream := client.Chat.Completions.NewStreaming(context.Background(),
		openai.ChatCompletionNewParams{
			Model: "<MODEL_NAME>",
			Messages: []openai.ChatCompletionMessageParamUnion{
				openai.UserMessage("What are the latest developments in quantum computing?"),
			},
		},
		option.WithJSONSet("web_search_options", map[string]any{}),
		option.WithJSONSet("pii_check_options", map[string]any{}),              // Optional
		option.WithJSONSet("prompt_injection_check_options", map[string]any{}), // Optional
	)

	for stream.Next() {
		chunk := stream.Current()
		if len(chunk.Choices) > 0 {
			fmt.Print(chunk.Choices[0].Delta.Content)
		}
	}
	if err := stream.Err(); err != nil {
		log.Fatal(err)
	}
}
```

```swift Swift theme={"dark"}
import TinfoilAI
import OpenAI

let client = try await TinfoilAI.create(
    apiKey: ProcessInfo.processInfo.environment["TINFOIL_API_KEY"] ?? ""
)

let query = ChatQuery(
    messages: [.user(.init(content: .string("What are the latest developments in quantum computing?")))],
    model: "<MODEL_NAME>",
    webSearchOptions: ChatQuery.WebSearchOptions(),
    stream: true
)

for try await result in client.chatsStream(query: query) {
    if let content = result.choices.first?.delta.content {
        print(content, terminator: "")
    }
}
```

```rust Rust theme={"dark"}
use futures_util::StreamExt;
use serde_json::json;
use tinfoil::Client;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new_default().await?;

    let body = client.chat_relaxed().request()
        .model("<MODEL_NAME>")
        .messages([json!(
            { "role": "user", "content": "What are the latest developments in quantum computing?" }
        )])
        .web_search_with_options(json!({}))
        .pii_check_with_options(json!({}))
        .set("prompt_injection_check_options", json!({}))
        .set("stream", true);

    let mut stream = client.chat_relaxed().create_stream(body).await?;

    while let Some(chunk) = stream.next().await {
        let chunk = chunk?;

        if let Some(annotations) = chunk
            .raw()
            .pointer("/choices/0/delta/annotations")
            .and_then(|v| v.as_array())
        {
            for ann in annotations {
                if ann.get("type").and_then(|v| v.as_str()) == Some("url_citation") {
                    let title = ann.pointer("/url_citation/title").and_then(|v| v.as_str()).unwrap_or("");
                    let url = ann.pointer("/url_citation/url").and_then(|v| v.as_str()).unwrap_or("");
                    println!("\nCitation: {} - {}", title, url);
                }
            }
        }

        if let Some(delta) = chunk.delta_content() {
            print!("{}", delta);
        }
    }
    Ok(())
}
```

```bash cURL theme={"dark"}
curl -N https://inference.tinfoil.sh/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TINFOIL_API_KEY" \
  -d '{
    "model": "<MODEL_NAME>",
    "messages": [
      { "role": "user", "content": "What are the latest developments in quantum computing?" }
    ],
    "web_search_options": {},
    "stream": true
  }'
```

### Responses (`/v1/responses`)

```typescript JavaScript theme={"dark"}
import { TinfoilAI } from 'tinfoil';

const client = new TinfoilAI({
  apiKey: process.env.TINFOIL_API_KEY,
});

const stream = await client.responses.create({
  model: '<MODEL_NAME>',
  input: 'What are the latest developments in quantum computing?',
  tools: [{ type: 'web_search' }],
  stream: true,
});

for await (const event of stream) {
  switch (event.type) {
    case 'response.web_search_call.in_progress':
    case 'response.web_search_call.searching':
    case 'response.web_search_call.completed':
      console.log(event.type, event.item_id);
      break;
    case 'response.output_text.delta':
      process.stdout.write(event.delta);
      break;
    case 'response.output_text.annotation.added':
      console.log('\nCitation:', event.annotation.title, event.annotation.url);
      break;
  }
}
```

```python Python theme={"dark"}
from tinfoil import TinfoilAI

client = TinfoilAI(api_key="<YOUR_API_KEY>")

stream = client.responses.create(
    model="<MODEL_NAME>",
    input="What are the latest developments in quantum computing?",
    tools=[{"type": "web_search"}],
    stream=True,
)

for event in stream:
    etype = getattr(event, "type", None)
    if etype == "response.output_text.delta":
        print(event.delta, end="", flush=True)
    elif etype == "response.output_text.annotation.added":
        ann = event.annotation
        print(f"\nCitation: {ann.title} - {ann.url}")
```

```rust Rust theme={"dark"}
// For raw JSON access, drive Responses through the verified HTTP client.
use serde_json::json;
use tinfoil::Client;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new_default().await?;
    let secure = client.secure_client();

    let response = secure.http_client()?
        .post(format!("{}/v1/responses", secure.base_url()))
        .bearer_auth(secure.api_key())
        .json(&json!({
            "model": "<MODEL_NAME>",
            "input": "What are the latest developments in quantum computing?",
            "tools": [{ "type": "web_search" }]
        }))
        .send()
        .await?
        .error_for_status()?
        .json::<serde_json::Value>()
        .await?;

    println!("{}", serde_json::to_string_pretty(&response)?);
    Ok(())
}
```

```bash cURL theme={"dark"}
curl -N https://inference.tinfoil.sh/v1/responses \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TINFOIL_API_KEY" \
  -d '{
    "model": "<MODEL_NAME>",
    "input": "What are the latest developments in quantum computing?",
    "tools": [{"type": "web_search"}],
    "stream": true
  }'
```

## Request options

### Top-level request fields

| Field | API | Required | Description |
| - | - | - | - |
| `web_search_options` | Chat Completions | Yes, to enable | Enables web search. Accepts the tuning fields listed below. |
| `tools: [{ "type": "web_search", ... }]` | Responses | Yes, to enable | Enables web search. Per-tool fields match `web_search_options`. |
| `pii_check_options` | Both | No | Mask detected PII in search queries before they are sent to Exa. Presence of the key enables the filter. |
| `prompt_injection_check_options` | Both | No | Filter prompt-injection attempts out of search results and fetched pages. Presence of the key enables the filter. |
| `include: ["web_search_call.action.sources"]` | Responses | No | Opt in to populating `action.sources` on `web_search_call` output items with the URLs each search returned. |

### Search tuning fields

These fields are all optional. They have the same meaning on both APIs. On Chat Completions they go under `web_search_options.<field>`; on Responses they go on the `web_search` tool entry (`tools[].<field>`).

| Field | Type | Description |
| - | - | - |
| `search_context_size` | `"low"` \| `"medium"` \| `"high"` | Retrieval-depth tier. `low` favors short highlight snippets, `medium` is the default, `high` pulls more results and longer content per result. |
| `user_location` | object | Approximate location context. Only `approximate.country` (ISO 3166-1 alpha-2) is honored today. |
| `filters.allowed_domains` | string\[] | Restrict search results to these hostnames. |
| `filters.excluded_domains` | string\[] | Drop these hostnames from search results. |
| `content_mode` | `"highlights"` \| `"text"` | Override what each result carries. Defaults to the tier choice implied by `search_context_size`. |
| `max_content_chars` | integer | Per-result character budget for returned content. Defaults to the tier choice implied by `search_context_size`. |
| `category` | string | Narrow search to a topical category (for example, `news`, `research paper`). |
| `start_published_date` | `YYYY-MM-DD` or RFC 3339 | Only return results published on or after this date. |
| `end_published_date` | `YYYY-MM-DD` or RFC 3339 | Only return results published on or before this date. |
| `max_age_hours` | integer | Only return results from the last N hours. |
| `external_web_access` | boolean | Set to `false` to keep web search off the live web: searches return only cached page content, and the model cannot open specific pages. `max_age_hours` is ignored when this is `false`. Defaults to `true`. |

Example combining several options on Chat Completions:

```json theme={"dark"}
{
  "model": "<MODEL_NAME>",
  "messages": [{ "role": "user", "content": "Best restaurants near me" }],
  "web_search_options": {
    "search_context_size": "medium",
    "user_location": {
      "type": "approximate",
      "approximate": { "country": "US" }
    },
    "filters": {
      "allowed_domains": ["yelp.com", "tripadvisor.com"]
    },
    "max_age_hours": 720,
    "category": "news"
  }
}
```

The equivalent on the Responses API:

```json theme={"dark"}
{
  "model": "<MODEL_NAME>",
  "input": "Best restaurants near me",
  "tools": [{
    "type": "web_search",
    "search_context_size": "medium",
    "user_location": {
      "type": "approximate",
      "approximate": { "country": "US" }
    },
    "filters": {
      "allowed_domains": ["yelp.com", "tripadvisor.com"]
    },
    "max_age_hours": 720,
    "category": "news"
  }],
  "include": ["web_search_call.action.sources"]
}
```

> [!NOTE]
>
> Safety filters are opt-in per request. Include `pii_check_options` to mask detected PII in queries before they reach Exa, and `prompt_injection_check_options` to filter injection attempts out of search results and fetched pages. Both are independent; enabling one does not enable the other.

## Response format

### Chat Completions

The response is a standard OpenAI `chat.completion`. Citations appear in two places:

* inline in the assistant text as ASCII markdown links (`[label](url)`),
* as structured `url_citation` annotations on the assistant message, whose `start_index` / `end_index` span the label text.

Non-streaming example:

```json theme={"dark"}
{
  "id": "chatcmpl-...",
  "object": "chat.completion",
  "choices": [{
    "index": 0,
    "message": {
      "role": "assistant",
      "content": "Quantum error correction reached a milestone in 2025 [Nature](https://www.nature.com/article/...).",
      "annotations": [{
        "type": "url_citation",
        "url_citation": {
          "url": "https://www.nature.com/article/...",
          "title": "Nature article title",
          "start_index": 44,
          "end_index": 50
        }
      }]
    },
    "finish_reason": "stop"
  }],
  "usage": { "prompt_tokens": 123, "completion_tokens": 456, "total_tokens": 579 }
}
```

In streaming mode, the same citations arrive as `delta.annotations` entries interleaved with `delta.content`:

```json theme={"dark"}
{
  "choices": [{
    "index": 0,
    "delta": {
      "annotations": [{
        "type": "url_citation",
        "url_citation": {
          "url": "https://www.nature.com/article/...",
          "title": "Nature article title",
          "start_index": 44,
          "end_index": 50
        }
      }]
    }
  }]
}
```

> [!NOTE]
>
> The Chat Completions stream is a standard `chat.completion.chunk` stream with no custom top-level events. If you want live search progress on Chat Completions, see [Streaming progress markers](#optional-streaming-progress-markers-chat-completions).

### Responses

The `response.output` array contains a `web_search_call` item for each search or page fetch, followed by the assistant `message` item. Citations are attached to each `output_text` content part as flat `url_citation` annotations.

```json theme={"dark"}
{
  "id": "resp_...",
  "object": "response",
  "status": "completed",
  "output": [
    {
      "type": "web_search_call",
      "id": "ws_abc123",
      "status": "completed",
      "action": {
        "type": "search",
        "query": "latest quantum error correction results 2025"
      }
    },
    {
      "type": "web_search_call",
      "id": "ws_def456",
      "status": "completed",
      "action": {
        "type": "open_page",
        "url": "https://www.nature.com/article/..."
      }
    },
    {
      "type": "message",
      "role": "assistant",
      "status": "completed",
      "content": [{
        "type": "output_text",
        "text": "Quantum error correction reached a milestone in 2025 [Nature](https://www.nature.com/article/...).",
        "annotations": [{
          "type": "url_citation",
          "url": "https://www.nature.com/article/...",
          "title": "Nature article title",
          "start_index": 44,
          "end_index": 50
        }]
      }]
    }
  ],
  "usage": { "input_tokens": 123, "output_tokens": 456, "total_tokens": 579 }
}
```

The annotation shape is flat on Responses (`{type, url, start_index, end_index, title}`) whereas Chat Completions nests it under `url_citation`.

When the request opts in with `include: ["web_search_call.action.sources"]`, each `search`-kind `web_search_call` also carries the URLs the search returned:

```json theme={"dark"}
{
  "type": "web_search_call",
  "id": "ws_abc123",
  "status": "completed",
  "action": {
    "type": "search",
    "query": "latest quantum error correction results 2025",
    "sources": [
      { "type": "url", "url": "https://www.nature.com/article/..." },
      { "type": "url", "url": "https://arxiv.org/abs/..." }
    ]
  }
}
```

### Streaming events (Responses)

Responses streaming emits OpenAI's standard events. The ones relevant to web search are:

| Event | When |
| - | - |
| `response.output_item.added` | A `web_search_call` item is surfaced, initially with `status: "in_progress"`. |
| `response.web_search_call.in_progress` | A search or page fetch is starting. |
| `response.web_search_call.searching` | A search is being sent to the provider. Page fetches do not emit this event. |
| `response.web_search_call.completed` | A search or fetch finished successfully. Not emitted on failure. |
| `response.output_item.done` | Terminal event for the item. `event.item.status` is `completed` or `failed`. |

Assistant text streams through the usual `response.output_text.delta` and `response.output_text.done` events. Citations arrive as `response.output_text.annotation.added`:

```json theme={"dark"}
{
  "type": "response.output_text.annotation.added",
  "output_index": 2,
  "item_id": "msg_...",
  "content_index": 0,
  "annotation_index": 0,
  "annotation": {
    "type": "url_citation",
    "url": "https://www.nature.com/article/...",
    "title": "Nature article title",
    "start_index": 44,
    "end_index": 50
  }
}
```

The stream terminates with a single `response.completed` event carrying the full `output` and `usage`.

### Failure statuses and PII masking

A search or page fetch that fails surfaces with `status: "failed"` on the terminal `web_search_call` item (OpenAI's `web_search_call.status` enum is `in_progress`, `searching`, `completed`, `failed`).

PII masking does not produce a failed status: search continues with the sanitized query and the item completes normally. The masking report rides on the optional [`_tinfoil` sidecar](#optional-the-_tinfoil-sidecar) as `_tinfoil.pii`. A failed PII check surfaces as `failed` with `_tinfoil.error.code: "tool_error"`.

## Optional: streaming progress markers (Chat Completions)

The OpenAI Chat Completions spec has no native event for web-search progress. If you want a live progress UI on Chat Completions (a spinner, a "searching the web…" line, a per-URL fetch indicator), you can opt in to **Tinfoil progress markers**.

Send the request header:

```
X-Tinfoil-Events: web_search
```

When markers are enabled, progress payloads are carried as tagged JSON inside the normal `delta.content` of `chat.completion.chunk` frames. Each marker is a standalone line:

```
<tinfoil-event>{"type":"tinfoil.web_search_call","item_id":"ws_...","status":"in_progress","action":{"type":"search","query":"..."}}</tinfoil-event>
```

The payload shape is:

```json theme={"dark"}
{
  "type": "tinfoil.web_search_call",
  "item_id": "ws_abc123",
  "status": "in_progress" | "completed" | "failed",
  "action": { "type": "search", "query": "..." }
             | { "type": "open_page", "url": "..." },
  "error": { "code": "tool_error" },
  "sources": [{ "url": "...", "title": "..." }],
  "pii": {
    "masked": true,
    "redacted_query": "...",
    "redactions": [{ "type": "private_email", "start": 0, "end": 16 }]
  }
}
```

* `status` follows a simple lifecycle: one `in_progress` marker when a search or fetch starts, followed by one terminal marker (`completed` or `failed`).
* `action.type` is `search` for web searches and `open_page` for page fetches. A search that triggers multiple page fetches produces one marker pair per URL. `action.query` is the query the model asked for, before any masking.
* `error` is only present on `failed` markers.
* `sources` is only present on terminal markers for `search` calls that produced results. Each entry is a `{url, title}` pair attributing a citation to this specific call. `title` may be an empty string; clients should fall back to the URL or hostname in that case.
* `pii` is only present on terminal `search` markers when the PII check ran. Its shape matches [`_tinfoil.pii`](#optional-the-_tinfoil-sidecar). A marker without `pii` means the check did not run, not that the query was clean.

The same marker pairs are also prefixed onto the assistant `content` string in non-streaming Chat Completions responses when the header is set, so you can render an identical progress timeline from either mode.

> [!NOTE]
>
> Clients that do not parse the markers will render them as text inside the assistant message. Either parse and strip them, or leave the header off to get a pristine stream with no markers.

### Consuming markers on the client

A single regex is enough to extract and strip markers. The leading and trailing newlines are absorbed so the text before and after a marker collapses seamlessly:

```
\n?<tinfoil-event>[\s\S]*?</tinfoil-event>\n?
```

```typescript JavaScript theme={"dark"}
const MARKER_RE = /\n?<tinfoil-event>([\s\S]*?)<\/tinfoil-event>\n?/g;

// For each chat.completion.chunk you receive from the SSE stream,
// run its delta.content through this helper before rendering it.
function onContentDelta(content: string) {
  const visible = content.replace(MARKER_RE, (_full, payload) => {
    try {
      const evt = JSON.parse(payload);
      if (evt.type === 'tinfoil.web_search_call') {
        renderSearchProgress(evt); // your own progress UI
      }
    } catch {
      // Ignore malformed markers; treat them as plain text.
    }
    return '';
  });
  if (visible) appendAssistantText(visible);
}
```

```python Python theme={"dark"}
import json, re

MARKER_RE = re.compile(r"\n?<tinfoil-event>([\s\S]*?)</tinfoil-event>\n?")

def on_content_delta(content: str) -> str:
    def _strip(m):
        try:
            evt = json.loads(m.group(1))
            if evt.get("type") == "tinfoil.web_search_call":
                render_search_progress(evt)  # your own progress UI
        except json.JSONDecodeError:
            pass
        return ""
    return MARKER_RE.sub(_strip, content)
```

> [!WARNING]
>
> The marker channel is Tinfoil-specific. If you want a portable progress UI, prefer the Responses API's native `response.web_search_call.*` events instead.

## Optional: the `_tinfoil` sidecar

On the Responses API, `web_search_call.status` is restricted to OpenAI's enum: `in_progress`, `searching`, `completed`, `failed`. Tinfoil exposes richer information through an optional vendor-extension field named `_tinfoil` that rides alongside the envelope:

```json theme={"dark"}
{
  "type": "web_search_call",
  "id": "ws_...",
  "status": "completed",
  "action": { "type": "search", "query": "john@example.com hiking trails" },
  "_tinfoil": {
    "pii": {
      "masked": true,
      "redacted_query": "hiking trails",
      "redactions": [{ "type": "private_email", "start": 0, "end": 16 }]
    }
  }
}
```

Rules:

* `_tinfoil` is present on failed calls and on `search` calls where the PII check ran. Successful calls with no PII check omit it entirely.
* `_tinfoil.error.code` is present on every failed call. Tool failures use `tool_error`.
* `_tinfoil.pii` is present on `search` calls when the PII check ran, including when nothing was masked (`masked: false`, empty `redactions`). Its absence means the check did not run, not that the query was clean.

`_tinfoil.pii` fields:

| Field | Meaning |
| - | - |
| `masked` | `true` when at least one span was removed from the query before it was sent to Exa. |
| `redacted_query` | The query that was actually searched. Matches `action.query` when nothing was masked. |
| `redactions` | Removed spans, ordered by position in `action.query`. Each carries a category (`type`) and zero-based Unicode code point offsets (`start` inclusive, `end` exclusive). The removed text is never repeated; slice `action.query` with the offsets to recover it. These are not UTF-8 byte or UTF-16 code unit offsets, so in JavaScript use `Array.from(action.query).slice(start, end).join("")` rather than `String.prototype.slice`. |

`action.query` is always the query the model asked for. Masking follows the model's detected span boundaries and may cover only part of a sensitive value, so neither `masked: true` nor the presence of `pii` guarantees the remaining query is free of PII. See [PII protection](#pii-protection) for the masking policy.

Strict OpenAI SDKs treat unknown object keys as no-ops, so `_tinfoil` is invisible unless you read it explicitly.

The sidecar appears on:

* the non-streaming `response.output[*]` `web_search_call` items,
* the streaming `response.output_item.done.item` for a `web_search_call`.

## Optional: usage reporting

To have aggregated token usage surfaced as an HTTP response header or trailer, send:

```
X-Tinfoil-Request-Usage-Metrics: true
```

Tinfoil returns the usage summary in `X-Tinfoil-Usage-Metrics`:

* as a response header for non-streaming requests,
* as an HTTP trailer for streaming requests.

When the model performed at least one search or page fetch, the summary includes `web_search_calls` with the number of calls, and `cost_usd` includes the web search fee:

```
prompt=1000,completion=500,total=1500,model=gpt-oss-120b,web_search_calls=2,cost_usd=0.052
```

The fee is charged once per request regardless of how many calls the model made. If `web_search_calls` is absent, the model did not use web search and no fee applies, even if web search was enabled on the request. This lets a [proxy server](/guides/proxy-server.md#usage-metrics-for-billing) attribute web search costs without decrypting the response body.

If you also want the final usage-bearing `chat.completion.chunk` on streaming Chat Completions, request it through standard OpenAI `stream_options`:

```json theme={"dark"}
{
  "stream": true,
  "stream_options": { "include_usage": true }
}
```

## PII protection

The `pii_check_options` field enables filtering of outgoing search queries. The privacy filter detects spans of personally identifiable information, and a policy removes selected spans before sending the remaining query to Exa. It does not reject the whole search just because PII was detected.

**Masking policy:**

* Detected personal emails (`private_email`), personal phone numbers (`private_phone`), account numbers (`account_number`), and secrets (`secret`) are removed.
* Detected private addresses (`private_address`) and dates (`private_date`) are removed when the same query also identifies a private person (`private_person`). The person's name is not itself removed.

**Left unchanged by this policy:**

* Names alone
* Dates or addresses without a detected private person
* Business or corporate contact information
* Public figures' public information

The policy depends on the model's detected categories; it is not a guarantee that every sensitive value will be recognized. Generic descriptions without identifying details are allowed.

If masking leaves an empty or whitespace-only query, Exa is not called and the search returns no results. If the PII check fails, the query is not sent to Exa and the `web_search_call` item surfaces as `failed`.

**Seeing what was masked:**

* On the Responses API, read [`_tinfoil.pii`](#optional-the-_tinfoil-sidecar) on each `web_search_call` item.
* On Chat Completions with [progress markers](#optional-streaming-progress-markers-chat-completions) enabled, read `pii` on the terminal `search` marker.
* Direct MCP callers read `pii_checked`, `pii_masked`, `redacted_query`, and `pii_redactions` in the [search result](/guides/mcp-websearch.md#response).

All three carry the same report: whether spans were masked, the sanitized query, and the removed spans as offsets into the original query. If the report is absent, filtering status is unknown.

## Prompt-injection protection

The `prompt_injection_check_options` field runs a safeguard model over each search snippet and fetched page before the content is handed back to the responding model. Results and pages that contain instructions aimed at hijacking the model (for example "ignore previous instructions", embedded tool-use directives, or credential-exfiltration prompts) are dropped.

When every result for a query is filtered out, the model sees an empty result set for that search and answers without web grounding. Fetch failures due to injection filtering surface as `status: "failed"` on the corresponding `web_search_call` item.

Prompt-injection filtering is opt-in per request. Omit the field to skip the check.

## Multi-turn conversations (Responses API)

The Responses API supports `previous_response_id` to continue a conversation across turns. Prior search results and fetched pages are carried forward so the model can build on them:

```json theme={"dark"}
{
  "model": "<MODEL_NAME>",
  "input": "Can you tell me more about the first result?",
  "previous_response_id": "resp_abc12345",
  "tools": [{ "type": "web_search" }]
}
```


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.