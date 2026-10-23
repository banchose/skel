> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# Error handling

> How to handle errors in the Tinfoil SDKs

## API Errors

Since the Tinfoil SDK wraps the OpenAI client, standard API errors (`AuthenticationError`, `RateLimitError`, etc.) pass through unchanged. The SDK re-exports them so you can import and catch them directly. See the [OpenAI error documentation](https://developers.openai.com/docs/guides/error-codes) for details.

> **Example: handling an AuthenticationError**
>
> ```typescript JavaScript theme={"dark"}
> import { TinfoilAI, AuthenticationError } from "tinfoil";
>
> const client = new TinfoilAI({
>   apiKey: "tk_invalid_key",
> });
>
> try {
>   await client.chat.completions.create({
>     model: "<MODEL_NAME>",
>     messages: [{ role: "user", content: "Hello!" }],
>   });
> } catch (err) {
>   if (err instanceof AuthenticationError) {
>     console.error("Invalid API key:", err.status, err.message);
>   }
> }
> ```
>
> ```rust Rust theme={"dark"}
> use tinfoil::async_openai::error::OpenAIError;
> use tinfoil::error::Error;
> use tinfoil::Client;
>
> let client = Client::new_default_with_api_key("tk_invalid_key").await?;
>
> match client.chat().create(request).await {
>     Err(OpenAIError::ApiError(api)) if api.code.as_deref() == Some("invalid_api_key") => {
>         eprintln!("Invalid API key: {}", api.message);
>     }
>     Err(other) => return Err(Error::from(other).into()),
>     Ok(_) => {}
> }
> ```

### Quota errors

Requests that exceed a spending or usage limit return `type` and `code` set to `insufficient_quota`. The HTTP status tells you which limit was hit:

| Status | Message | Cause |
| - | - | - |
| `429` | `Spend limit reached for this API key.` | The key's `max_cost` cap |
| `429` | `Input token limit reached for this API key.` | The key's `max_input_tokens` cap |
| `429` | `Output token limit reached for this API key.` | The key's `max_output_tokens` cap |
| `402` | `You exceeded your current quota, please check your plan and billing details.` | The account or organization has no remaining balance or an inactive subscription |

Per-key caps are lifetime totals set by an admin; see [Create API Key](/admin/admin-api.md#create-api-key). A `429` from a per-key cap is not transient, so retrying will not help. Raise or clear the cap with [Update API Key](/admin/admin-api.md#update-api-key), or use a different key.

Both kinds of limit are evaluated against usage that has already been recorded. Requests still in flight when a limit is reached complete and are billed, and new requests start failing a few seconds later. See [How usage is recorded](/admin/admin-api.md#how-usage-is-recorded).

```json theme={"dark"}
{
  "error": {
    "message": "Spend limit reached for this API key.",
    "type": "insufficient_quota",
    "code": "insufficient_quota"
  }
}
```

## Client Errors

The SDK verifies attestations, pins certificates, and encrypts payloads before any data leaves your machine. It retries transient failures automatically, but errors that persist will surface to your code as one of three typed errors.

```
TinfoilError (base)
├── ConfigurationError  — Client misconfigured
├── FetchError          — Attestation materials could not be fetched
└── AttestationError    — Attestation verification failed
```

All errors extend `TinfoilError`, which extends the native `Error` class. Each error includes a `message` string and an optional `cause` property containing the underlying error.

| Error | Cause | What to do |
| - | - | - |
| `ConfigurationError` | Bad or missing client options | Fix your code. Retrying will not help. |
| `FetchError` | Network or HTTP failure while fetching attestation materials | Retry network failures. For a persistent HTTP error, such as `501` for an unsupported enclave, inspect `cause`. |
| `AttestationError` | Attestation verification failed | Retry. If it persists, it may indicate a genuine security issue. |

The `tinfoil` package does not export `FetchError`. Catch it as `TinfoilError`, or check `err.name === "FetchError"`.

In practice, you typically only need to distinguish `ConfigurationError` (a bug in your code) from transient errors:

```typescript JavaScript theme={"dark"}
import { TinfoilAI, ConfigurationError, TinfoilError } from "tinfoil";

try {
  const completion = await client.chat.completions.create({
    model: "<MODEL_NAME>",
    messages: [{ role: "user", content: "Hello!" }],
  });
} catch (err) {
  if (err instanceof ConfigurationError) {
    // Fix your config and create a new client
  } else if (err instanceof TinfoilError) {
    // Transient or security error — you can retry or surface to the user
    console.error(err.message, err.cause); // cause has the underlying error
  }
}
```

```rust Rust theme={"dark"}
use tinfoil::error::Error;
use tinfoil::Client;

match client.chat().create(request).await.map_err(Error::from) {
    Ok(completion) => { /* use completion */ }
    Err(err) if err.is_configuration() => {
        // Fix your config and create a new client
    }
    Err(err) if err.is_attestation() => {
        // Security-relevant: do not retry blindly
        eprintln!("attestation failure: {}", err);
    }
    Err(err) if err.is_retryable() => {
        // Transient — fetch error or 5xx/429 from the upstream API
        eprintln!("transient error, retrying: {}", err);
    }
    Err(err) => return Err(err.into()),
}
```


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.