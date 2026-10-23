> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# Prompt caching

> Reuse prompt prefixes across requests with automatic cache scoping in the Tinfoil SDKs.

## Prompt caching

Prompt caching lets the inference router reuse work from an earlier request when a later request uses the same model and begins with the same prompt prefix. The first request populates the cache. Later requests can reuse the matching prefix while it remains available, reducing latency and the work required before generating new tokens.

See [API pricing](https://tinfoil.sh/pricing#api) for the latest cached-token rates for selected models. For the design and security details behind this feature, read the [secure prompt caching blog post](https://tinfoil.sh/blog/2026-07-14-secure-prompt-caching).

To get the most out of caching, put stable content, such as system instructions and tool definitions, near the beginning of the prompt and request-specific content later. Changing an earlier token shortens or eliminates the reusable prefix.

Caching requires a minimum prompt length, roughly a few thousand characters. Shorter prompts do not trigger caching even when the model and prefix match. Cached prefixes are also matched in fixed-size chunks, so the reported `cached_tokens` count can be smaller than the full matching prefix.

Prompt caches are temporary and may be evicted. Your application must remain correct when a request does not produce a cache hit.

## Cache lifetime and retention

Cached prefixes live only in the GPU memory of the model enclave that served the request. The cache is never written to disk, exported, or shared between enclaves, and it does not survive an enclave restart. A prefix stays cached until the inference server evicts it to make room for newer work. There is no fixed expiration time; under production load, a prefix that is not reused is typically evicted within minutes, and at the tail within hours.

A cache entry holds the model's internal key-value state for the prefix, not the prompt text, and it is only addressable through the cache namespace derived from your API identity and `user_cache_secret`. Because the cache is volatile enclave memory, the retention statement for the Inference API is unchanged by caching: Tinfoil does not retain prompt or response content after a response is returned.

Generating a fresh `user_cache_secret` for every request does not change what is stored or for how long. It only guarantees that no two requests share a namespace, so no request ever gets a cache hit. If you want cache isolation without losing the benefit, use one stable secret per user or session instead.

## How the SDKs handle it

You do not need to configure anything to benefit from prompt caching. Each Tinfoil SDK automatically manages a value called `user_cache_secret` that scopes which requests can share cached prefixes:

1. The SDK resolves a stable secret. By default it generates a random one and stores it at `~/.tinfoil/user_cache_secret`, so SDK clients on the same machine reuse it. Browsers and other environments without usable persistence use a runtime-lifetime value instead.
2. The SDK adds the secret to eligible JSON `POST` requests to `/v1/chat/completions`, `/v1/completions`, and `/v1/responses`. Endpoints that do not use prompt-prefix caching, such as embeddings, audio, files, models, and realtime WebSockets, do not receive the secret.
3. The router combines the secret with your authenticated API identity to select a cache namespace. Requests reuse cached prefixes only when the API identity, secret, model, and prompt prefix all match.

`user_cache_secret` is used only for cache partitioning. It is not an API credential or encryption key, and it does not encrypt prompts or cache entries. Treat it as sensitive application data and avoid logging it, since requests sharing an identity and secret also share cache-hit timing.

## Configuring the secret

Most applications can use the generated default. When your deployment needs different scoping, you can override the secret at three levels. The first non-empty value wins:

1. A `user_cache_secret` string set in an individual request body.
2. The client option (for example `userCacheSecret` in JavaScript or `user_cache_secret` in Python).
3. The `TINFOIL_USER_CACHE_SECRET` environment variable.

Otherwise the SDK falls back to the generated secret. Empty values at any level are treated as unset.

Choose the scope that matches your deployment:

* **Single-user application:** use the generated default.
* **Multi-user application:** provide a stable, distinct, non-empty value for each user (or group that may share a cache) on every eligible request.
* **Multiple containers or machines:** use the same stable, non-empty value wherever requests should share one cache.

Use opaque random values rather than raw user identifiers or API keys. Without a per-user secret, requests under the same API identity share one cache, so a client-level or environment-level value alone does not separate users in a multi-user service.

Requests sent through a raw HTTP client, or direct API access without an SDK, do not get a secret injected automatically and must set the field themselves where cache separation is required.

## Minimum SDK versions

Use at least these SDK versions to benefit from secure prompt caching:

| SDK | Minimum version |
| - | - |
| Python | `0.13.5` |
| JavaScript | `1.1.10` |
| Go | `0.14.3` |
| Rust | `0.1.3` |
| Swift | `0.6.4` |


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.