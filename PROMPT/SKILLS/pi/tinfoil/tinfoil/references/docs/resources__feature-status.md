> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# Feature status

> Which features are part of the V3 attestation beta.

## V3 attestation is beta

**V3 attestation and every feature that depends on it are beta** while deployment is ongoing. Beta features may change as deployment continues.

| Feature | Status |
| - | - |
| [Private secrets and keyserver delivery](/containers/private-secrets.md) | **Beta** |
| [Encrypted persistent volumes](/containers/encrypted-volumes.md) | **Beta**, including manual unlock and [automatic unlock](/containers/volume-auto-unlock.md) |
| [Attested keys](/containers/attested-keys.md) and [attested SSH](/containers/attested-ssh.md) | **Beta** |
| [Fresh attestation from containers](/containers/attestation.md) | **Beta** |
| V3 verification in the [Go SDK](/sdk/go-sdk.md), [Swift SDK](/sdk/swift-sdk.md), and [Tinfoil Proxy](/local-proxy/app.md) | **Beta** when using a release or build with V3 verification |
| [CLI attestation verification and verified connections](/sdk/cli-sdk.md) | **Beta**; these commands use V3 |
| [V3 workload release pinning and freshness checks](/verification/verification-in-tinfoil.md#pinning-the-expected-workload) | **Beta** |

The beta designation applies whether you use these features through the dashboard, CLI, API, or SDK.

## Other beta features

[Harbor and custom registry support](/containers/private-images.md#harbor-and-other-registries) are also beta.

## Features outside the V3 beta

Features that do not depend on V3 retain their current status. [Tinfoil-managed secrets and environment variables](/containers/secrets-and-env-vars.md), [container lifecycle management](/containers/lifecycle.md) without beta features, and [S3 storage with the buckets sidecar](/containers/persistent-storage.md) are outside the V3 beta.

The inference API and remote attestation as a whole are not labeled beta by this rollout. If you use a V3-based client to access inference or a container, that verification path is beta. SDK support varies by release; see the status notes on each SDK page.


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.