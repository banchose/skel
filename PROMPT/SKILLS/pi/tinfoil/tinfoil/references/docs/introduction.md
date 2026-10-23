> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# Introduction

> Tinfoil is a private AI platform that enables you to build and deploy AI applications with end-to-end privacy guarantees using secure hardware enclaves. Use Tinfoil Inference, our OpenAI-compatible API, or Tinfoil Containers to build AI-powered applications. All security claims and attestations are verified automatically through our SDKs.

> [!NOTE]
>
> V3 attestation and features that depend on it are **beta** while deployment is ongoing. See [Feature status](/resources/feature-status.md) for the beta features and the scope of this designation.

## What Tinfoil provides

**Hardware-enforced Privacy** - User request data is processed inside secure enclaves
that even Tinfoil cannot access, giving you hardware-enforced privacy that
is verifiable via remote attestation.

**Transparent Security** - All our security-critical code is open source.
You can verify that your data was processed in a secure enclave running
the *exact* code we've published on GitHub. All our SDKs are configured
to verify attestation and supply chain security automatically on each connection.

**Drop-in Compatibility** - Our inference platform supports an OpenAI-compatible API for a variety of
open-source models. All the Tinfoil SDKs are compatible with the OpenAI API, so switching requires minimal code changes.

## Quick Start

The easiest way to get started is by using one of the Tinfoil SDKs to make some inference requests to an AI model. It's as easy as getting an API key and running one of our examples.

> **[Try it now](https://chat.tinfoil.sh)**
>
> Try Tinfoil Chat in your browser, with its built-in Verification Center.

## Learn more about Tinfoil

### Read about our security architecture

If you'd like to learn more about the technology, specifically how confidential
computing with secure enclaves works, you can read more on that in
[our primer on secure enclaves](/verification/secure-enclave-primer.md).

If you'd like to understand the technical components of how Tinfoil works and the
design details of our security architecture, you can read about
[how verification works](/verification/verification-in-tinfoil.md) and our
[backend infrastructure](/verification/attestation-architecture.md).

### Read our technical guides

Learn more about implementing specific features with:

> **[Tool Calling](/guides/tool-calling.md)**
>
> Use function calling to let AI models interact with external tools and APIs.

> **[Structured Outputs](/guides/structured-outputs.md)**
>
> Use JSON schema validation for reliable data extraction and structured responses.

> **[Image Processing](/guides/image-processing.md)**
>
> Process images with multi-modal AI models using base64 encoding.

> **[Document Processing](/guides/document-processing.md)**
>
> Upload and process documents securely through the conversion API or OpenAI-compatible file inputs.

### **Tutorials**

Step-by-step guides for common use cases:

> **[Code Gen with Cline](/tutorials/coding-agents.md#cline)**
>
> Use Tinfoil with the Cline VSCode extension for private AI-assisted coding that keeps your code private.

> **[Self-Improving AI with Hermes](/tutorials/coding-agents.md#hermes-agent)**
>
> Use the Nous Research Hermes Agent with Tinfoil for a self-improving AI assistant with private inference.


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.