# Verification & attestation

How Tinfoil proves "this enclave runs exactly the open-source code and weights
we published, and only it can decrypt your request."

## Three parties

1. **Trusted client** — runs a Tinfoil SDK (or proxy/CLI).
2. **Untrusted host** — machine operated by Tinfoil; hypervisor/root cannot read
   enclave memory (hardware memory encryption).
3. **Secure enclave** — confidential VM running the workload (vLLM for
   inference, or your container).

## What the SDK checks on every connection

1. Fetch the hardware-signed **attestation report** from the enclave.
2. Verify its certificate chain back to the CPU vendor root (AMD for SEV-SNP,
   Intel for TDX; NVIDIA for GPU CC).
3. Fetch the **Sigstore bundle** produced by the GitHub Actions build
   (`measure-image-action`) of the config repo
   (default `tinfoilsh/confidential-model-router`).
4. Compare attestation measurements (firmware, kernel, initrd, kernel cmdline
   containing the `tinfoil-config.yml` hash) to the Sigstore-published ones.
5. Bind the session to the attested key: TLS pinning (`transport: 'tls'`) or
   HPKE public key for **EHBP** (`transport: 'ehbp'`, the default).

Any failure ⇒ SDK refuses to send data (`AttestationError`).

## Chained enclaves

`inference.tinfoil.sh` is the **confidential model router**, itself an enclave.
It load-balances across model enclaves, routes prefix-sharing requests to the
same enclave (prompt cache), runs server-side tools (web search, doc input) via
tool enclaves, and reports token usage for billing.

Because the router reads plaintext, it must be verified too — the client
verifies the router; the router verifies every model/tool enclave before
forwarding. The repo trusted for each model is compiled into the router's
measured code, so re-pointing a model at different code requires publishing a
new router release (visible in the transparency log). Router→enclave traffic is
encrypted to the key in that enclave's attestation.

## Supply chain

- `tinfoil-config.yml` (public repo) pins: OVMF firmware, CVM image, model
  weight commitment, container image digests, resources.
- `measure-image-action` builds the enclave image on a release tag and
  publishes a Sigstore keyless-signed bundle of expected measurements to the
  public append-only transparency log (Rekor).
- CVM image: minimal Ubuntu, stripped kernel, reverse proxy terminating TLS and
  serving attestation, read-only image and weight disks, byte-for-byte
  reproducible.
- **Modelwrap**: weights are loaded after boot (not CPU-measured), so they're
  packaged as a dm-verity volume whose root hash is pinned in the config; the
  enclave rejects mismatched volumes.
- Firmware version is in the attestation report ⇒ newer SDKs can refuse
  known-vulnerable configurations. **Keep SDKs updated.**

## V3 attestation (beta, 2026)

Go, Swift and CLI SDKs use V3 verification (beta while rollout continues);
Python, JS, Rust are outside the beta. V3-dependent features: workload release
pinning, freshness checks, Containers' private secrets, encrypted volumes,
attested keys/SSH. See https://docs.tinfoil.sh/resources/feature-status.md.

## EHBP (Encrypted HTTP Body Protocol)

Application-layer encryption of request/response **bodies** with HPKE
(RFC 9180) to the attested enclave key, independent of TLS. Headers remain
visible to intermediaries — so a backend proxy can add auth/API key/rate limits
without seeing content. Works through proxies; TLS-pinning mode does not.
Spec: https://docs.tinfoil.sh/resources/ehbp. npm package `ehbp` (dependency
of `tinfoil`).

## Debug containers

Containers' debug mode (SSH-enabled) deliberately fails attestation;
`SecureClient` refuses to connect. Never route real data to a debug instance.
