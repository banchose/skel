> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# Backend infrastructure

> This page provides a description of the different components that make up our backend infrastructure. It also describes how Tinfoil guarantees code auditability and data confidentiality using these components.

## Prerequisites

This page assumes some familiarity with the different parts of the
Tinfoil system and the goals associated with attestation and
supply chain transparency verification.

We recommend reading the [technical overview](/verification/verification-in-tinfoil.md)
first to familiarize yourself.

## Backend infrastructure

The backend architecture is illustrated in Figure 1. All security-critical
components are open source and available on GitHub.

![Tinfoil Attestation Architecture](https://mintcdn.com/tinfoil/QPXTScLceEkhaLM_/images/diagrams/backend-diagram.jpeg?fit=max\&auto=format\&n=QPXTScLceEkhaLM_\&q=85\&s=96830c1363a5b7b96c6c943ef06be937)

Figure 1: Overview of Tinfoil's backend infrastructure and attestation architecture.

> [!NOTE]
>
> The diagram omits billing and user account management. These are closed-source
> orchestration-layer components that do not receive prompt or response content.
> The Tinfoil Backend receives usage metadata from the attested router, as
> described in [Usage reporting and billing](#usage-reporting-and-billing).

### The Secure Enclave Components

The secure enclave consists of the OVMF firmware that boots the confidential VM (CVM) image.
The CVM serves the attestation and terminates the TLS connection from clients.

#### Confidential VM Image

A [confidential VM](https://github.com/tinfoilsh/cvmimage) (CVM) is a virtual machine whose memory is encrypted by the
CPU so that the host operator (including the hypervisor and any privileged
software) cannot read or tamper with its contents. This is the foundation of
[confidential computing](/verification/secure-enclave-primer.md). Tinfoil's CVM
image is a minimal Ubuntu image with a stripped down kernel; Ubuntu provides the
broad driver and package support that GPU workloads need.
At runtime, the CVM runs a reverse proxy that terminates
TLS and serves the attestation document, the user's workload
(e.g., an inference server), and any supporting services like model weight
verification. The image and model weight disks are mounted read-only. The firmware,
kernel, and initrd are measured into the attestation report at boot
time, while read-only model weight volumes are verified separately
with dm-verity and checked against the expected values from the
Sigstore bundle during verification.
The image is built additively from
pinned inputs and is byte-for-byte reproducible; see
[CVM image: TCB and reproducible builds](/verification/cvm-image.md) for
what it contains and how to rebuild it.

#### OVMF Firmware

When a confidential VM starts, the very first code that runs is its boot
firmware. This firmware is essentially the "BIOS" of the confidential VM and
initializes the hardware, sets up memory encryption, and hands off to the Linux kernel.
The firmware is the first thing measured by the CPU for the attestation report.
To ensure reproducibility, Tinfoil uses [a pinned version of the OVMF firmware](https://github.com/tinfoilsh/edk2).
Each build is attested to Sigstore and the exact firmware binary running in the
enclave can be verified against the build log.

### Supply Chain Security Architecture

Outside of the secure enclave, we have a release pipeline that provides
supply chain security for all components that become part of the enclave.
This starts with pinned releases of the firmware, CVM image, and model weights.
The sha256 hash of each of these is configured inside a `tinfoil-config.yml`
which is then committed to a public GitHub repo. A GitHub action runs to
create a release consisting of the build and hardware measurements.
These measurements are then committed to a public append-only transparency log.

#### Modelwrap: attested model weights

Model weights are loaded from disk after boot, so the CPU does not measure them.
Instead, they are packaged as a read-only volume whose cryptographic commitment
(a dm-verity root hash) is pinned in `tinfoil-config.yml`. At runtime, the enclave
rejects any weight volume that doesn't match the commitment.
[modelwrap](https://github.com/tinfoilsh/modelwrap) builds these volumes from
Hugging Face weights and verifies them inside the enclave. See our
[technical blog post](https://tinfoil.sh/blog/2026-02-03-proving-model-identity) for details.

#### tinfoil-config.yml

The Tinfoil configuration file is a manifest specifying the model commitment (generated via modelwrap),
container images, CVM version, and resource allocation. It is committed to a
deployment repo and its SHA256 hash is embedded in the kernel command line,
creating a cryptographic link between the config and the running enclave.
This config file is used by the measure-image-action GitHub action to generate
hardware measurements that get pinned to the transparency log.

#### measure-image-action

The [measure-image-action](https://github.com/tinfoilsh/measure-image-action) is our
GitHub Actions workflow that turns a `tinfoil-config.yml` into a measured release.
When a new release is tagged and pushed to the config repo,
this workflow builds the enclave image and publishes a signed
Sigstore bundle containing the expected measurements,
linking the open source code to the attested binary.
This bundle is signed with a Sigstore keyless certificate issued for the GitHub Actions workflow and committed to the Sigstore transparency log
making it impossible for us to change the code without also changing
the expected attestation measurements.

### Hardware Attestation

Hardware attestation is the process by which the CPU and GPU produce
cryptographic proof of what code is running inside the enclave. This proof
is what clients verify, in tandem to the bundles committed to the transparency log
at build time, before sending any data.

#### Boot sequence and CPU measurement

When a confidential VM starts, the CPU measures each stage of the boot
process — hashing the code and configuration at each step — and records
the results in a hardware-signed attestation report. Here is the sequence
of what happens during boot:

1. **Firmware**: The [OVMF firmware](#ovmf-firmware) initializes the VM.
   Because it is the very first code to execute, it is also the first thing
   the CPU measures and includes in the attestation report.

2. **Kernel**: The OS kernel and initrd load from the read-only root
   filesystem. These are also measured by the CPU.

3. **Configuration verification**: The
   [boot process](https://github.com/tinfoilsh/cvmimage/blob/main/tinfoil/cmd/boot/main.go)
   checks that the `tinfoil-config.yml` on disk matches the attested hash
   embedded in the kernel command line. This ensures the enclave is running
   the exact configuration that was committed to during the
   [build](#supply-chain-security-architecture).

4. **Model weight verification**: Read-only model weight volumes are mounted
   and verified against their
   [modelwrap](#modelwrap-attested-model-weights) commitments
   using [dm-verity](https://docs.kernel.org/admin-guide/device-mapper/verity.html).
   dm-verity is a Linux kernel subsystem that intercepts every disk read and
   validates it against a Merkle tree root hash, ensuring that no block of
   data has been tampered with. See our
   [blog post on proving model identity](https://tinfoil.sh/blog/2026-02-03-proving-model-identity)
   for a deeper explanation.

5. **Service startup**: The reverse proxy and workload containers start
   using the configuration from the attested config.

The CVM image itself is stateless: its disks are mounted read-only and ephemeral
data uses a ramdisk created at boot, so nothing persists between boots. The
exception is opt-in [encrypted persistent volumes](/containers/encrypted-volumes.md)
for Tinfoil Containers. A volume becomes writable only after the enclave receives
its customer-held key. Its contents are encrypted and integrity-protected, but not
protected against replay of older sectors or restoration of an older copy of the disk.
They are data rather than code and are not part of the attestation measurement.

#### GPU verification

For GPU workloads, the boot process includes an additional step: it checks the
attestation of each NVIDIA GPU with NVIDIA's [`nvattest`](https://github.com/NVIDIA/attestation-sdk)
tool to verify the GPU is running in confidential computing mode.
This creates a chain of trust from the CPU to the GPU. If the CPU fails to
verify the GPU's attestation, it aborts the boot process and the enclave
does not start. Because the GPU attestation is linked to the CPU attestation
report, clients verifying the CPU attestation are also transitively
verifying the GPU configuration.

### Client-side verification

Before exchanging application data (e.g., chat completions)
with an enclave, the [Tinfoil SDK](/sdk/overview.md) verifies the enclave's identity
and integrity. The SDK fetches the
[attestation document](/verification/predicate.md) from the enclave, which
includes signed runtime measurements, and verifies the certificate chain back
to the CPU's hardcoded root
certificate ([AMD](https://github.com/tinfoilsh/tinfoil-go/tree/main/verify/internal/quote/sev)).
It then fetches the Sigstore bundle, verifies its
signatures against Sigstore's [root trust anchor](https://github.com/tinfoilsh/tinfoil-go/blob/main/verify/internal/endorsement/trusted_root.json),
and checks the [measurement predicates](/verification/predicate.md#supported-formats)
to ensure the source code and runtime enclave measurements match. Finally, it
opens a TLS connection and confirms the server's public key matches the one in
the attestation document, binding TLS to the attested key and guaranteeing that
the connection terminates inside a verified enclave.

#### Attestation Proxies

Verification needs the enclave's attestation document, the hardware
manufacturer's certificate chain, and the Sigstore bundle from GitHub. To reduce
round-trips, Tinfoil operates caching proxies for this material:

* An attestation bundle proxy that returns everything the verifier needs in one
  response: the enclave's attestation report, the certificate chain, the Sigstore
  bundle, and the enclave's TLS certificate. The [JavaScript SDK](/sdk/javascript-sdk.md)
  uses it by default.
* `github-proxy.tinfoil.sh`, which caches GitHub release data, including the
  Sigstore bundles published by the [measure-image-action](https://github.com/tinfoilsh/measure-image-action).
* `kds-proxy.tinfoil.sh`, which caches AMD Key Distribution Service (KDS)
  certificates used to validate the CPU attestation.

None of these proxies is trusted. The client checks everything they return against
the AMD root certificate embedded in the
[verifier code](https://github.com/tinfoilsh/tinfoil-go/tree/main/verify/internal/quote/sev)
and Sigstore's trust anchor, so a proxy can withhold material but cannot forge it.

## Transport Security

Tinfoil uses two complementary mechanisms to ensure data is encrypted
end-to-end to verified enclaves: TLS key binding and the
Encrypted HTTP Body Protocol (EHBP).

### TLS Key Binding

TLS key binding ensures all TLS sessions terminate inside a verified enclave,
never on a non-enclave host. The enclave’s attestation includes an
enclave-generated TLS public key tied to the measured runtime,
and terminates TLS inside the enclave (inside the CVM) with a non-exportable
private key that never leaves enclave memory. The client verifier compares
the server's TLS key to the attested key. If they differ, verification fails
and no data is sent. This guarantees that only verified enclaves can decrypt
traffic; intermediaries can forward TCP but cannot terminate or read plaintext.

### Encrypted HTTP Body Protocol (EHBP)

In environments where TLS certificate pinning is not available (such as
browsers), or where the connection needs to pass through an intermediate
server for billing, authentication, or rate limiting, Tinfoil uses
[EHBP](/resources/ehbp.md) to encrypt HTTP request and response bodies
end-to-end. The SDK fetches the enclave’s attested HPKE public key and
encrypts all message bodies directly to that verified key using
[HPKE (RFC 9180)](https://datatracker.ietf.org/doc/html/rfc9180). HTTP
headers remain in the clear for routing, but the payload is only
decryptable by the attested enclave. This provides the same data confidentiality
guarantee as TLS key binding for request and response bodies, for clients that cannot pin certificates.

A common pattern is to run a proxy server on your backend that adds your
API key and handles user authentication, while EHBP ensures the proxy
never sees the plaintext request or response bodies. See the
[proxy server guide](/guides/proxy-server.md) for a complete walkthrough
with code examples.

## Chaining Enclaves

In some deployments, multiple enclaves work together to serve a single
request. Each enclave in the chain verifies the next one before forwarding
data, extending the same attestation guarantees across the entire pipeline.

For example, in our inference API backend, verification is chained across
two enclaves. The client SDK verifies the
[confidential model router](https://github.com/tinfoilsh/confidential-model-router),
which runs in its own enclave. The router then verifies the target model
enclave before forwarding the request. Data is encrypted end-to-end at
each hop using attested keys, so neither the host nor the router can read
plaintext outside of a verified enclave.

### How the router admits model enclaves

The router only forwards to enclaves it has verified against a fixed model-to-repository mapping. That mapping (`config.yml` in the router repository) is compiled into the router binary, so it is covered by the router's own measurement. Changing which repository serves a model requires a new router release, which produces a new measurement that clients verify. The Tinfoil Backend supplies only the list of enclave hostnames at runtime; it cannot change the repository a model is bound to.

For each candidate enclave, the router:

1. Fetches the enclave's attestation document and verifies the hardware quote (AMD SEV-SNP or Intel TDX) against the vendor's certificate chain.
2. Resolves the latest release of the model's repository, verifies its Sigstore bundle against the Sigstore trust root (including Rekor transparency log inclusion), and reads the expected measurement from the signed predicate.
3. Compares the attested measurement to the expected one. Enclaves that do not match are never routed to.
4. Pins the TLS public key from the attestation for every request forwarded to that enclave.

The router repeats this check periodically and whenever an enclave's TLS key changes, and it stops routing to an enclave whose attestation has expired.

### Inspecting the admitted enclave set

`GET https://inference.tinfoil.sh/.well-known/tinfoil-proxy` returns the router's current view of every model it serves: the bound repository, the verified release tag, the expected measurement, and, for each admitted enclave hostname, the attestation predicate type, TLS key fingerprint, and HPKE public key. The `errors` list shows any enclaves that failed verification and were excluded.

This endpoint is served from inside the attested router enclave. Combine it with the router's own verification to turn it into evidence: first verify the router with the CLI, then read the manifest over the verified connection.

```bash theme={"dark"}
tinfoil attestation verify -e inference.tinfoil.sh -r tinfoilsh/confidential-model-router
curl https://inference.tinfoil.sh/.well-known/tinfoil-proxy
```

Each response also carries a `Tinfoil-Enclave` header naming the model enclave hostname that served it. To audit a specific model release independently of the router, verify its repository directly:

```bash theme={"dark"}
tinfoil attestation verify -e <ENCLAVE_HOSTNAME> -r tinfoilsh/confidential-<MODEL_NAME>
```

Model enclave hostnames restrict inbound connections, so direct verification may not be reachable from arbitrary networks. The release artifacts themselves (`tinfoil-deployment.json`, `tinfoil.hash`, and the Sigstore bundle) are public on each repository's GitHub releases page and can be verified offline.

## Usage reporting and billing

Token usage is collected inside the confidential model router and reported to the
Tinfoil Backend for billing:

1. **The model reports usage to the router.** The model enclave returns token
   counts to the router enclave with each response.
2. **The router sends usage records to the Tinfoil Backend** within a few seconds
   of each response.
3. **The Tinfoil Backend accounts for usage.** It attributes the usage to your
   account and updates usage totals and billing.

For token-based model requests, the records contain input, cached input, and output
token counts; the model; a timestamp; the API key for account attribution; request
identifiers; the API route; and the serving enclave. They do not contain prompt
text or generated response text.

To enforce usage and rate limits, the router also sends the API key and requested
model to the Tinfoil Backend. Neither exchange carries prompt or
response content.

These are explicit outbound channels from the router enclave to the Tinfoil Backend.
The privacy boundary is enforced by the code that constructs these messages
inside the enclave. That code is open source and part of the measured router
workload: auditing it shows what is exported, and attestation verification ties
the running workload to its published build.

To inspect the implementation, see the router's
[response processing](https://github.com/tinfoilsh/confidential-model-router/blob/main/manager/proxy.go),
[usage record construction](https://github.com/tinfoilsh/confidential-model-router/blob/main/billing/events.go),
and [limit checks](https://github.com/tinfoilsh/confidential-model-router/blob/main/route_context.go).
For completion timing, interrupted streams, and usage limits, see
[How usage is recorded](/admin/admin-api.md#how-usage-is-recorded).


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.