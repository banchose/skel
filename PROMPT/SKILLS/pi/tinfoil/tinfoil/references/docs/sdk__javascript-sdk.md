> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# JavaScript

> JavaScript SDK for Tinfoil's secure AI inference API

> **[View on GitHub](https://github.com/tinfoilsh/tinfoil-js)**
>
> tinfoilsh/tinfoil-js

## Overview

The Tinfoil JavaScript SDK is a wrapper around the [OpenAI Node client](https://github.com/openai/openai-node) that provides secure communication with Tinfoil enclaves. It has the same API as the OpenAI SDK with additional security features including automatic verification that the endpoint is running in a secure Tinfoil enclave, TLS certificate pinning, and attestation validation.

All payloads are encrypted end-to-end using [EHBP](/resources/ehbp.md) (Encrypted HTTP Body Protocol), which encrypts data directly to the attested enclave using HPKE (RFC 9180).

## Installation

```bash theme={"dark"}
npm install tinfoil
```

**Requirements:** Node 20+

## Quick Start

```typescript theme={"dark"}
import { TinfoilAI } from "tinfoil";

const client = new TinfoilAI({
  apiKey: "<YOUR_API_KEY>", // or use TINFOIL_API_KEY env var
});

const completion = await client.chat.completions.create({
  messages: [{ role: "user", content: "Hello!" }],
  model: "llama3-3-70b",
});
```

> [!NOTE]
>
> Do not set `baseURL` unless you are routing through [your own proxy server](/guides/proxy-server.md).

## Migration from OpenAI

Migrating from OpenAI to Tinfoil is straightforward. The client is designed to be compatible with the [OpenAI Node](https://github.com/openai/openai-node/) client:

```diff theme={"dark"}
// Before (OpenAI)
- import OpenAI from 'openai';
- 
- const client = new OpenAI({
-   apiKey: process.env.OPENAI_API_KEY,
- });

// After (Tinfoil)
+ import { TinfoilAI } from 'tinfoil';
+ 
+ const client = new TinfoilAI({
+   apiKey: process.env.TINFOIL_API_KEY
+ });
```

All method signatures remain the same since `TinfoilAI` extends the standard OpenAI client.

## Browser Support

The SDK supports browser environments for direct API access from web applications.

> [!WARNING]
>
> **Security Warning:** Using API keys directly in the browser exposes them to anyone who can view your page source. For production applications, always use a backend server to handle API keys.

### Browser Usage

```typescript theme={"dark"}
import { TinfoilAI } from 'tinfoil';

const client = new TinfoilAI({
  apiKey: '<YOUR_API_KEY>',
  dangerouslyAllowBrowser: true // Required for browser usage
});

// Optional: pre-initialize
await client.ready();

const completion = await client.chat.completions.create({
  model: 'llama3-3-70b',
  messages: [{ role: 'user', content: 'Hello!' }]
});
```

**Browser Requirements:**

* Modern browsers with ES2020 support
* Web Crypto API support for enclave verification

## Running the Chat Example

To run the streaming chat example:

1. Clone the repository

2. Install dependencies:

```bash theme={"dark"}
npm install
```

3. Create a `.env` file with your configuration:

```bash theme={"dark"}
TINFOIL_API_KEY=<YOUR_API_KEY>
```

4. Run the example:

```bash theme={"dark"}
cd examples/chat
npx ts-node main.ts
```

The example demonstrates streaming chat completions with the Tinfoil API wrapper.

## Usage

```typescript theme={"dark"}
// 1. Create a client
const client = new TinfoilAI({
  apiKey: process.env.TINFOIL_API_KEY,
});

// 2. Use client as you would OpenAI client 
// see https://github.com/openai/openai-node for API documentation
```

## Model Examples

Below are specific examples for each supported model. Click on any model to see its configuration and usage example.

### Chat Models

> **GLM-5.3**
>
> ```typescript theme={"dark"}
> import { TinfoilAI } from 'tinfoil';
>
> const client = new TinfoilAI({
>   apiKey: process.env.TINFOIL_API_KEY
> });
>
> // Example: Complex reasoning task
> const response = await client.chat.completions.create({
>   model: 'glm-5-3',
>   messages: [
>     {
>       role: 'user',
>       content: 'Solve this step by step: If a train travels 120 miles in 2 hours, and then increases its speed by 25% for the next 3 hours, how far does it travel in total?'
>     }
>   ]
> });
>
> console.log(response.choices[0]?.message?.content);
> ```

> **Gemma 4 31B**
>
> ```typescript theme={"dark"}
> import { TinfoilAI } from 'tinfoil';
> import fs from 'fs';
>
> const client = new TinfoilAI({
>   apiKey: process.env.TINFOIL_API_KEY
> });
>
> // Example: Image analysis
> const imageBuffer = fs.readFileSync('image.jpg');
> const base64Image = imageBuffer.toString('base64');
>
> const response = await client.chat.completions.create({
>   model: 'gemma4-31b',
>   messages: [
>     {
>       role: 'user',
>       content: [
>         { type: 'text', text: "What's in this image?" },
>         {
>           type: 'image_url',
>           image_url: {
>             url: `data:image/jpeg;base64,${base64Image}`
>           }
>         }
>       ] as any
>     }
>   ]
> });
>
> console.log(response.choices[0]?.message?.content);
> ```

> **Llama 3.3 70B**
>
> ```typescript theme={"dark"}
> import { TinfoilAI } from 'tinfoil';
>
> const client = new TinfoilAI({
>   apiKey: process.env.TINFOIL_API_KEY
> });
>
> // Example: Conversational AI
> const response = await client.chat.completions.create({
>   model: 'llama3-3-70b',
>   messages: [
>     {
>       role: 'user',
>       content: 'What are the key differences between renewable and non-renewable energy sources?'
>     }
>   ]
> });
>
> console.log(response.choices[0]?.message?.content);
> ```

> **GPT-OSS 120B**
>
> ```typescript theme={"dark"}
> import { TinfoilAI } from 'tinfoil';
>
> const client = new TinfoilAI({
>   apiKey: process.env.TINFOIL_API_KEY
> });
>
> // Example: Advanced reasoning with configurable effort levels
> const response = await client.chat.completions.create({
>   model: 'gpt-oss-120b',
>   messages: [
>     {
>       role: 'user',
>       content: 'Analyze the trade-offs between different database architectures for a high-traffic e-commerce platform.'
>     }
>   ]
> });
>
> console.log(response.choices[0]?.message?.content);
> ```

### Audio Models

> **Voxtral Small 24B**
>
> #### Transcription
>
> ```typescript theme={"dark"}
> import fs from "fs";
> import { TinfoilAI } from 'tinfoil';
>
> const client = new TinfoilAI({
>   apiKey: process.env.TINFOIL_API_KEY
> });
>
> // Example: Audio transcription
> const audioFile = fs.createReadStream("meeting_recording.mp3");
> const transcription = await client.audio.transcriptions.create({
>   model: "voxtral-small-24b",
>   file: audioFile,
>   language: "en", // Optional: specify language for better accuracy
>   prompt: "This is a business meeting discussing quarterly results" // Optional: provide context
> });
>
> console.log("Transcription:", transcription.text);
> ```
>
> #### Audio Q\&A
>
> ```typescript theme={"dark"}
> import fs from "fs";
> import { TinfoilAI } from 'tinfoil';
>
> const client = new TinfoilAI({
>   apiKey: process.env.TINFOIL_API_KEY
> });
>
> // Load audio and encode as base64
> const audioData = fs.readFileSync("audio.mp3");
> const audioBase64 = audioData.toString("base64");
>
> const response = await client.chat.completions.create({
>   model: "voxtral-small-24b",
>   messages: [{
>     role: "user",
>     content: [
>       { type: "text", text: "How many words are in this audio?" },
>       {
>         type: "input_audio",
>         input_audio: { data: audioBase64, format: "mp3" }
>       }
>     ]
>   }]
> });
>
> console.log(response.choices[0].message.content);
> // Output: "The audio contains 600 words."
> ```

### Embedding Models

> **Nomic Embed Text**
>
> ```typescript theme={"dark"}
> import { TinfoilAI } from 'tinfoil';
>
> const client = new TinfoilAI({
>   apiKey: process.env.TINFOIL_API_KEY
> });
>
> // Example: Generate embeddings for similarity search
> const documents = [
>   "Artificial intelligence is transforming modern technology.",
>   "Machine learning enables computers to learn from data.",
>   "The weather today is sunny and warm.",
>   "Deep learning uses neural networks with multiple layers."
> ];
>
> // Generate embeddings for all documents
> const embeddings: number[][] = [];
> for (const doc of documents) {
>   const response = await client.embeddings.create({
>     model: "nomic-embed-text",
>     input: doc,
>     encoding_format: "float"
>   });
>   embeddings.push(response.data[0].embedding);
> }
>
> // Calculate similarity between first two documents
> const dotProduct = (a: number[], b: number[]) => 
>   a.reduce((sum, val, i) => sum + val * b[i], 0);
> const magnitude = (vec: number[]) => 
>   Math.sqrt(vec.reduce((sum, val) => sum + val * val, 0));
>
> const similarity = dotProduct(embeddings[0], embeddings[1]) / 
>   (magnitude(embeddings[0]) * magnitude(embeddings[1]));
>
> console.log(`Similarity between first two AI-related documents: ${similarity.toFixed(3)}`);
> console.log(`Embedding dimension: ${embeddings[0].length}`);
> ```

## API Documentation

This library is a drop-in replacement for the [official OpenAI Node.js client](https://github.com/openai/openai-node) that can be used with Tinfoil. All methods and types are identical. See the [OpenAI client](https://github.com/openai/openai-node) for complete API usage and documentation.

## Advanced

### Transport Modes

The SDK supports two transport modes via the `transport` option:

* **`'ehbp'`** (default): HPKE encryption via the Encrypted HTTP Body Protocol
* **`'tls'`**: TLS certificate pinning (requires direct connection to the enclave)

```typescript theme={"dark"}
// TinfoilAI client
const client = new TinfoilAI({
  apiKey: process.env.TINFOIL_API_KEY,
  transport: 'ehbp' // or 'tls'
});

// SecureClient (low-level)
const secureClient = new SecureClient({
  transport: 'tls'
});
```

EHBP is the preferred transport as it works in browsers and supports [reverse proxies](/guides/proxy-server.md). TLS mode uses certificate pinning which only works in Node.js environments. See the [EHBP documentation](/resources/ehbp.md) for details.

### SecureClient

For custom integrations, the SDK exposes a `SecureClient` class with low-level access to the secure transport layer and verification information:

```typescript theme={"dark"}
import { SecureClient } from "tinfoil";

const client = new SecureClient();

try {
  await client.ready();

  const response = await client.fetch('/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.TINFOIL_API_KEY}`
    },
    body: JSON.stringify({
      model: 'llama3-3-70b',
      messages: [{ role: 'user', content: 'Hello!' }]
    })
  });

  if (response.ok) {
    const data = await response.json();
    console.log('Response:', data.choices[0]?.message?.content);
  }

  const doc = await client.getVerificationDocument();
  console.log('Security verified:', doc.securityVerified);
} catch (error) {
  // Even on error, access the verification document
  const doc = await client.getVerificationDocument();

  // Document contains detailed step information:
  // - fetchDigest: GitHub release digest retrieval
  // - verifyCode: Code measurement verification
  // - verifyEnclave: Runtime attestation verification
  // - compareMeasurements: Code vs runtime measurement comparison
  // - createTransport: Transport initialization (optional)
  // - verifyHPKEKey: HPKE key verification (optional)
  // - otherError: Catch-all for unexpected errors (optional)

  console.log('Security verified:', doc.securityVerified);

  // Check individual steps
  if (doc.steps.verifyEnclave.status === 'failed') {
    console.log('Enclave verification failed:', doc.steps.verifyEnclave.error);
  }
}
```

### What the verifier checks

The JavaScript verifier runs the same code in Node.js and the browser. On each connection it enforces:

* **Hardware attestation**: the AMD SEV-SNP report signature and the VCEK certificate chain back to the AMD root, with minimum firmware and TCB versions and debug mode disabled.
* **Code provenance**: the Sigstore bundle for the expected release, verified against a bundled Sigstore trust root, including the Fulcio certificate chain, the signed certificate timestamp, Rekor transparency log inclusion, and a GitHub Actions identity for the expected repository on a tag ref.
* **Measurement match**: the attested launch measurement equals the measurement in the signed release predicate.
* **Key binding**: the TLS certificate's subject alternative names commit to the attested HPKE public key and to a hash of the attestation document, and match the expected hostname.

Any failure throws an `AttestationError` and the client refuses to send data.

The JavaScript verifier does not implement the freshness witness, revocation, or Intel TDX checks in the [Go V3 verifier](/resources/feature-status.md) Beta. In particular:

* `verifiedAt` in the verification document is the local clock reading when verification completed. It is not an attested time and not a freshness bound.
* Release selection comes from the [attestation bundle proxy](/verification/attestation-architecture.md#attestation-proxies), which serves the router's current release. The verifier checks that release is validly signed and matches the enclave; it does not enforce a maximum release age or a minimum version. Compare `releaseDigest` in the verification document against the release you expect if you need rollback resistance. See [In-band vs. out-of-band verification](/verification/verification-in-tinfoil.md#in-band-vs-out-of-band-verification).
* The attestation bundle proxy only supports AMD SEV-SNP routers. A request for a TDX enclave returns `501 Not Implemented`, which surfaces as a [`FetchError`](/sdk/error-handling#client-errors).

For connection-time freshness and revocation checks, use [Go SDK](/sdk/go-sdk.md), [Swift SDK](/sdk/swift-sdk.md), or [CLI](/sdk/cli-sdk.md) releases with [beta V3 verification](/resources/feature-status.md), or run the CLI as an audit-time check alongside a JavaScript client.


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.