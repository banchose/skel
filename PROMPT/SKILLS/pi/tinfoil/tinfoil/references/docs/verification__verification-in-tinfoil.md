> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# How verification works in Tinfoil

> A technical overview of how Tinfoil guarantees code auditability, supply chain security, and data confidentiality with client-side verification.

## Overview

> [!NOTE]
>
> **V3 attestation is beta** while deployment is ongoing. Features that depend on V3, including workload release pinning and freshness checks, share that status. See [Feature status](/resources/feature-status.md) for the scope of the beta.

This page explains the basics of how Tinfoil provides **verifiable** privacy on
each connection. Tinfoil uses [confidential computing
enabled by secure hardware enclaves](/verification/secure-enclave-primer.md) to create a *verifiably private* runtime
environment in the cloud. The hardware measures and attests the code running in the enclave
and we connect these measurements to open source code using transparency logs
to ensure end-to-end supply chain security.

To make it easier to understand the different components involved, we must first
cover the three main parts that make up the Tinfoil system. We have:

* a trusted client that runs one of the Tinfoil SDKs and makes requests,
* an untrusted host machine operated by Tinfoil, and
* a secure hardware enclave that runs a server in isolation from the host.

Client requests get sent using the Tinfoil SDK to the server running in the enclave.
Before sending any data, the SDK automatically verifies that:

1. The enclave server is running code that is auditable and immutable
2. The enclave server computation is isolated from the host operator
3. The client request data is end-to-end encrypted to the enclave (only the enclave can decrypt it)

### Example: Tinfoil Inference

To provide a concrete example, consider [Tinfoil Inference](https://tinfoil.sh/inference).
Simplifying slightly, we have an enclave with an AI model loaded inside of it.
This enclave is running an open-source inference server (we use vLLM) that serves the
model and exposes the /v1/chat/completions API endpoint.
A client sends encrypted requests to this endpoint.
The enclave decrypts these requests (only the enclave has the decryption key) and forwards them to the inference
server running inside. The response is then encrypted and sent back to the client.

#### The problem of code transparency and confidentiality

How can the client be convinced that the enclave is running vLLM as the
inference server and not some other (potentially evil) code?
Additionally, how can the client verify the end-to-end encryption is enforced to the enclave and isn't man-in-the-middled by the host?
You can easily imagine a scenario where the host *pretends* to be the enclave and
decrypts the clients request, violating confidentiality.
We answer these questions in two parts.

## Part I: Verifying code transparency with remote attestation

The first thing the client needs to be able to do is verify that the enclave
is configured correctly and running the expected code.
This is achieved with remote attestation, which is rooted in the hardware manufacturer.

The CPU comes with secret key material fused into it by the manufacturer (e.g., Intel or AMD).
Keys rooted in that material sign the initial configuration and state of
the CPU and memory at boot time. The host cannot access these keys, and
extracting them is assumed impossible.

At boot time, the hardware measures the initial state, generating
a signed attestation report of the exact launch configuration, such as the
firmware, kernel,
security parameters, and the application binary running in the enclave.
The attestation report can be seen as a cryptographic fingerprint of this
entire launch configuration. If the same configuration is loaded twice, the fingerprints match.
However, if any component differs (e.g., a firmware change, a modified kernel, or a
different binary) then the fingerprints won't match.

This gets us part of the way towards full code transparency. The missing link
is connecting the fingerprint to human-readable code that can be inspected
for correctness and audited for security.

### Linking fingerprints to code

All the code running inside the enclave is published to our GitHub and made open source.
In theory, you could rebuild the binary and derive the corresponding expected cryptographic measurements or "fingerprint" yourself.
Upon connection, if the fingerprint you derived matches the one presented by the secure enclave through remote attestation,
then you can be convinced that the code running in the enclave was built from the open-source
code published on our GitHub repo.

However, rebuilding is expensive: you need to download the code, build it, and
derive the expected measurements before you can compare fingerprints.
That is fine for an occasional audit but too slow to run on every connection.

#### Leveraging transparency logs

Instead we use GitHub CI to build the byte-for-byte reproducible binary, derive and publish the expected
measurements to an immutable transparency log (we use Sigstore, managed by the
[Linux Foundation](https://www.linuxfoundation.org/)).
The log independently attests
that GitHub produced the "ground truth" fingerprint from isolated GitHub workers, and anyone can compare it to the
one received from the Tinfoil enclave.

The transparency log proves which binary was built; it does not by itself prove that
the binary matches the published source. To close that gap, the CVM image is built
reproducibly, so an auditor can rebuild it and confirm the logged measurement is the
measurement of the public code. See
[CVM image: TCB and reproducible builds](/verification/cvm-image.md).

### Pinning the expected workload

The Go V3 verifier and Tinfoil CLI support **beta** workload release pinning. They accept a repository reference that specifies which workload releases you trust:

| Reference | What it requires |
| - | - |
| `owner/repo` | A release from that repository with valid provenance and a current freshness witness |
| `owner/repo@v1.2.3` | The authenticated release tag must also be `v1.2.3` |
| `owner/repo@sha256:<DIGEST>` | The signed deployment artifact must have this exact digest |
| `owner/repo@v1.2.3@sha256:<DIGEST>` | Both the release tag and artifact digest must match |

The digest is the SHA-256 of the deployment artifact authenticated by the release's provenance statement, written as 64 lowercase hexadecimal characters. Choose the tag and digest from the release you intend to trust. A digest pin fixes the artifact's contents as well as requiring the expected repository identity.

A repository reference without a tag accepts currently witnessed releases from that repository; it does not require the latest GitHub release. Every form retains the normal hardware, provenance, and freshness checks. Code and platform freshness witnesses have a maximum age of seven days by default.

The same reference grammar pins registry configs: `org/project[@revision][@sha256:<DIGEST>]` names a [config registry](/containers/cli.md#creating-an-instance) project, its revision, and the config digest. For registry references the name-to-digest binding is authenticated by the signed config endorsement rather than a GitHub release's provenance statement; the constraint semantics per form are the same.

Use a workload pin to control which code you accept. A TLS or SSH key pin then binds your connection to a key endorsed by that verified workload. An enclave reboot can change its connection keys while the workload release stays the same. See [CLI release pinning](/sdk/cli-sdk.md#pin-a-release) and [Attested SSH](/containers/attested-ssh.md#pin-the-workload-release).

## Part II: Providing end-to-end encryption

The second problem is ensuring that the connection from the client is encrypted directly to the enclave.
How can the client verify that the public key it is encrypting all the requests with
was generated by the enclave and not the host? This requires tying the
public key to the signed attestation report, proving it was generated by the enclave itself.

At boot time, the enclave generates an encryption key pair, consisting of a public
key and a secret key. The secret key is
stored in the enclaves encrypted memory while the public key is made part of the
attestation report.

When the client connects to the enclave, all data sent over that connection is
encrypted using the enclave's attested public key.
The enclave's TLS certificate also carries a hash of its attestation report,
which binds the report to a `*.tinfoil.sh` domain so that a third-party enclave
running the same code cannot pose as a Tinfoil enclave. See
[Attestation evidence in certificate transparency](#attestation-evidence-in-certificate-transparency).

## How our SDKs automatically verify everything

Our SDKs are all open-source and run all verification logic client side.
We do not use any
proprietary or third party attestation services to verify
attestation reports since doing so results in circular security and defeats
the point of doing any verification in the first place.

On each connection, our SDKs
automatically fetch the expected enclave measurements from
GitHub and Sigstore and then proceed to verify the enclave attestation report.

First, the SDK verifies the code's Sigstore bundle against the expected
repository and any [release pin](#pinning-the-expected-workload).
Second, it obtains the attestation report generated by the remote enclave.
Our SDKs may fetch this material through Tinfoil-operated caching proxies.
This adds no trust in Tinfoil: each component is signed independently by
Sigstore or the hardware manufacturer, and the SDK checks those signatures itself.

Once all the verification material is assembled, the SDK compares the expected
Sigstore-provided measurements to the enclave-attestation measurements,
if these don't match, the SDK throws an error and stops all connections
from being established.

On the other hand, if the measurements match, then the client creates an
encrypted connection to the enclave using the public key from the attestation report.

## Chaining enclaves

The process described above is what happens when you connect to
`inference.tinfoil.sh` with one of our SDKs. That hostname is the
[confidential model router](https://github.com/tinfoilsh/confidential-model-router),
which runs in its own secure enclave. Each model is served by one or more model
enclaves, and the router forwards every request to one of them:

* It picks a healthy, verified enclave for the requested model, spreading load and
  steering away from overloaded enclaves. Requests that share a prompt prefix can be
  sent to the same enclave so they reuse its [prompt cache](/sdk/prompt-caching.md).
* With `model: "auto"`, it also chooses which model serves the request.
* It runs server-side features that need the request content, such as
  [web search](/guides/web-search.md) and [document inputs](/guides/document-processing.md),
  by calling dedicated tool enclaves.
* It checks usage limits and records token usage for billing. See
  [Usage reporting and billing](/verification/attestation-architecture.md#usage-reporting-and-billing).

Because the router reads requests to do this work, it must be verified like any
other enclave. The solution is to chain enclaves. The client-side SDKs verify the
router enclave, and the router verifies every model and tool enclave before
forwarding data to it. The repository trusted for each model is compiled into the
router's measured code, so Tinfoil cannot point a model at different code without
publishing a new router release. Traffic from the router to each enclave is
encrypted to the TLS key in that enclave's attestation, so request data is only
ever decrypted inside verified enclaves.

By chaining the attestations, we get end-to-end code transparency and confidentiality,
even though the client-side SDKs only need to verify the first enclave in this chain.
See [How the router admits model enclaves](/verification/attestation-architecture.md#how-the-router-admits-model-enclaves)
for the exact checks.

![Tinfoil Simple Attestation Architecture](https://mintcdn.com/tinfoil/QPXTScLceEkhaLM_/images/diagrams/simple-attestation-architecture.jpeg?fit=max\&auto=format\&n=QPXTScLceEkhaLM_\&q=85\&s=b5c53345455b61a06946263f272c443a)

Figure 1: Simple view of model router and inference attestation.

## In-band vs. out-of-band verification

The verification described above is **connection-time (in-band)** verification: the client verifies the enclave's attestation before exchanging any data. This is what our [SDKs](/sdk/overview.md) do automatically on every connection.

Tinfoil records the evidence needed for **audit-time (out-of-band)** verification in append-only transparency logs. Tinfoil does not provide a supported tool for querying these records and reconstructing the verification, so use an SDK's connection-time verification for real-time guarantees.

### Attestation evidence in certificate transparency

Audit-time verification relies on embedding attestation evidence into TLS
certificates, which are then recorded in public [certificate transparency (CT)](https://certificate.transparency.dev/) logs.
This serves two purposes: (1) it creates a public audit trail of every enclave boot,
and (2) it binds the attestation to a `*.tinfoil.sh` domain, preventing a
third-party enclave from impersonating a Tinfoil-controlled enclave.

At boot time, each enclave generates a fresh TLS key pair and an HPKE key pair for application-layer encryption (used by [EHBP](/resources/ehbp.md)).
It then requests a CPU attestation report that covers both public keys,
cryptographically binding them to the measured enclave state.
A hash of the attestation report is embedded in the Subject Alternative Name (SAN) field
of the enclave's TLS certificate. The enclave itself requests this certificate for its
`*.tinfoil.sh` domain from a public certificate authority over ACME, so the TLS private key
never leaves the enclave. Like every publicly trusted certificate, it is recorded in public CT logs.

The resulting certificate ties together the enclave's TLS and HPKE public keys, its CPU attestation report,
and its `*.tinfoil.sh` domain into a single publicly logged artifact.

> **[Backend Infrastructure Deep Dive](/verification/attestation-architecture.md)**
>
> Explore the full backend architecture, including the CVM image, Sigstore integration, and the build-to-deployment lifecycle.


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.