> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# Overview

> Overview of Tinfoil SDKs and their use cases

The Tinfoil SDKs are drop-in replacements for OpenAI clients with automatic security verification on every connection. Available for Python, TypeScript/Node, Go, Rust, and Swift. The CLI can also act as a reverse proxy.

## Available SDKs

V3 attestation verification in the Go and Swift SDKs, CLI, and [Tinfoil Proxy](/local-proxy/app.md) is [beta](/resources/feature-status.md) while deployment is ongoing. This label applies to client versions that use V3.

Read the full documentation for your SDK:

> **[Python](/sdk/python-sdk.md)**

> **[JavaScript](/sdk/javascript-sdk.md)**

> **[Go](/sdk/go-sdk.md)**

> **[Rust](/sdk/rust-sdk.md)**

> **[Swift](/sdk/swift-sdk.md)**

> **[CLI](/sdk/cli-sdk.md)**

If you'd like to see an SDK for a different language or runtime, please reach out at [contact@tinfoil.sh](mailto:contact@tinfoil.sh) and we'll prioritize adding support for it.

## Why you should use the SDKs

The SDKs make it easy to integrate Tinfoil into your applications without having to
worry about encryption, attestation verification, or other security pitfalls.
All the privacy and integrity features offered by Tinfoil are automatically verified
for you and all connections are blocked in case of verification failure.

Each SDK is designed to be a **drop-in replacement** for OpenAI clients.
This means you can continue to use the chat completions or responses API formats
with Tinfoil models. However, not all backend features are supported or enabled
for all models. If you experience issues, please don't hesitate to contact us.

For accessing the inference endpoint directly via HTTPS without an SDK (which we discourage for production workloads), see [Direct API Access](/sdk/direct-api-access.md).

## Guides

> **[Prompt Caching](/sdk/prompt-caching.md)**
>
> Reuse prompt prefixes with automatic per-user cache scoping.

> **[Web Search](/guides/web-search.md)**
>
> Enable AI models to search the web with optional PII protection.

> **[Tool Calling](/guides/tool-calling.md)**
>
> Learn how to use function calling capabilities with AI models.

> **[Structured Outputs](/guides/structured-outputs.md)**
>
> Use JSON schema validation for reliable data extraction.

> **[Image Processing](/guides/image-processing.md)**
>
> Process images with multimodal AI models.

> **[Document Processing](/guides/document-processing.md)**
>
> Upload and process documents securely.

> **[Proxy Server](/guides/proxy-server.md)**
>
> Keep your API key server-side while preserving end-to-end encryption.


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.