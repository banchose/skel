> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# CLI

> Command-line interface for verifying Tinfoil enclave attestations and making verified HTTP requests

> **[View on GitHub](https://github.com/tinfoilsh/tinfoil-cli)**
>
> tinfoilsh/tinfoil-cli

## Overview

The Tinfoil CLI verifies enclave attestations, makes verified HTTP requests against Tinfoil enclaves, and opens verified TCP tunnels into your containers. For a local OpenAI-compatible proxy, see the [Local Proxy](/local-proxy/app.md) section.

> [!NOTE]
>
> CLI commands that use V3 attestation to verify enclave connections are [beta](/resources/feature-status.md) while deployment is ongoing. This includes attestation verification, HTTP requests, proxies, TCP tunnels, and attested SSH.

## Installation

### Pre-built Binaries

Download the latest release for your OS from the [Releases](https://github.com/tinfoilsh/tinfoil-cli/releases) page.

### Install Script

You can install tinfoil CLI using our install script. This script automatically detects your operating system and architecture, downloads the correct binary, and installs it to `/usr/local/bin`.

```bash theme={"dark"}
curl -fsSL https://github.com/tinfoilsh/tinfoil-cli/raw/main/install.sh | sh
```

> [!NOTE]
>
> The installer uses `sudo` to install to `/usr/local/bin` when you are not root. To install without elevated permissions, download a pre-built binary and place it in a writable directory on your `PATH`.

### Build from Source

1. Ensure you have Go installed.
2. Clone the repository:

```bash theme={"dark"}
git clone https://github.com/tinfoilsh/tinfoil-cli.git
cd tinfoil-cli
```

3. Build the binary:

```bash theme={"dark"}
go build -o tinfoil
```

## Updating the CLI

Install the latest stable CLI release on Linux or macOS without logging in or providing an API key:

```bash theme={"dark"}
tinfoil update
```

The command downloads the release for your platform, verifies its published SHA-256 checksum, and replaces the local executable. It leaves running workloads, configuration, and keys unchanged. If you already have the latest stable release, no installation is needed.

The checksum checks download integrity; you still trust GitHub and the release publisher.

### Check without installing

Fetch fresh release metadata and report whether a newer version is available, without downloading release assets or changing files:

```bash theme={"dark"}
tinfoil update --check
```

Both updating and checking support `-o json`. For a read-only, machine-readable check:

```bash theme={"dark"}
tinfoil update --check -o json
```

The JSON fields are `current_version`, `latest_version`, and `status`. Status is `available` when a check finds a newer release, `up-to-date` when the installed version is equal to or newer than the latest stable release, or `installed` after a successful update. A successful installation also includes `path`, the replaced executable's resolved path.

### Permissions and managed installations

* The installation directory must allow binary replacement. The updater never invokes `sudo`. If permission is denied, rerun the [installer](#install-script) or use an account with the required permissions. If you choose to use `sudo`, invoke the trusted CLI by its verified absolute path rather than relying on `sudo`'s `PATH`.
* Homebrew-managed binaries cannot be replaced by self-update; update them through your package manager instead.
* Source builds with a `dev` or unknown version refuse self-update, including `--check`. Rebuild from source or install a published release.

### Update notices

In an interactive terminal, the CLI checks for newer releases at most once a day and prints a notice suggesting `tinfoil update`. This passive check does not download or install an update. Set `TINFOIL_NO_UPDATE_CHECK=1` to disable only the passive check; explicit `tinfoil update` and `tinfoil update --check` still work.

## Command Reference

The CLI provides these high-level command families:

* **Verification and connectivity:** `attestation`, `proxy`, `http`, `forward`, `ssh`, `scp`, and `attest-ssh`. See [TCP tunnels and SSH](/containers/connecting.md#tcp-tunnels-and-ssh) for the tunnel commands and [Attested SSH](/containers/attested-ssh.md) for native SSH profiles.
* **Authentication:** `login`, `logout`, and `whoami`.
* **Container management:** `container`, `project`, `model`, and `repo`.
* **Organization resources:** `volume`, `secret`, `ssh-key`, `registry`, and `domain`.

Run `tinfoil <command> --help` for the installed command reference. See [Managing containers from the CLI](/containers/cli.md) for container workflows and the [CLI repository](https://github.com/tinfoilsh/tinfoil-cli) for release notes.

## HTTP Requests

The `http` command makes verified HTTP requests to Tinfoil enclaves with attestation verification.

### GET Request

```bash theme={"dark"}
tinfoil http get https://inference.tinfoil.sh/health \
  -e inference.tinfoil.sh \
  -r tinfoilsh/confidential-model-router
```

### POST Request

```bash theme={"dark"}
tinfoil http post https://inference.tinfoil.sh/v1/chat/completions \
  -e inference.tinfoil.sh \
  -r tinfoilsh/confidential-model-router \
  -H "Authorization: Bearer $TINFOIL_API_KEY" \
  -H "Content-Type: application/json" \
  -b '{"model": "<MODEL_NAME>", "messages": [{"role": "user", "content": "Hello"}]}'
```

#### Streaming

Use the `-s` flag to stream the response line by line:

```bash theme={"dark"}
tinfoil http post https://inference.tinfoil.sh/v1/chat/completions \
  -e inference.tinfoil.sh \
  -r tinfoilsh/confidential-model-router \
  -H "Authorization: Bearer $TINFOIL_API_KEY" \
  -H "Content-Type: application/json" \
  -s \
  -b '{"model": "<MODEL_NAME>", "stream": true, "messages": [{"role": "user", "content": "Hello"}]}'
```

### Command Options

* `-b, --body`: HTTP POST body
* `-H, --header`: HTTP request header, in `Name: Value` format. May be repeated
* `-s, --stream`: Stream response output (POST only)

## Pin a release

Use `--repo` to select the workload you trust:

| `--repo` value | Constraint |
| - | - |
| `owner/workload` | Any release from this repository with valid provenance and a current freshness witness |
| `owner/workload@v1.2.3` | Require the authenticated release tag `v1.2.3` |
| `owner/workload@sha256:<DIGEST>` | Require the exact signed deployment artifact |
| `owner/workload@v1.2.3@sha256:<DIGEST>` | Require both the tag and artifact digest |

Replace `<DIGEST>` with the deployment artifact's SHA-256, written as 64 lowercase hexadecimal characters. A repository-only reference does not require the latest release. See [Pinning the expected workload](/verification/verification-in-tinfoil.md#pinning-the-expected-workload) for how these constraints are verified.

To verify a specific release:

```bash theme={"dark"}
tinfoil attestation verify \
  --enclave enclave.example.com \
  --repo owner/workload@v1.2.3
```

The CLI uses the default seven-day maximum age for freshness witnesses. It does not expose flags for changing that window or supplying arbitrary measurement-register pins.

## Connection policy

When the CLI resolves a container by name (`container connect`, `forward`,
`ssh`, `scp`, `attest-ssh`), the expected config comes from your local
connection policy — not from the resolution answer. The policy is
`~/.tinfoil/known-configs.yml`, yours to edit; the CLI preserves your
comments when it writes:

```yaml theme={"dark"}
mode: prompt
record: project
allow:
  orgs:
    - myorg                 # whole org, written deliberately
  projects:
    - myorg/my-api          # any revision of this project
  pins:                     # exact configs; also the connect journal
    - myorg/my-api@v1.2.3@sha256:ab…
```

An entry grants exactly what it says. Every allowed connect also journals the
exact config it resolved to into `pins` (`New config journaled: …`), so
tightening the policy later starts from everything you have actually used.

A config with no matching entry asks for confirmation in a terminal — yes
records it at the `record` granularity (`org`, `project`, or `pin`) — and
fails closed in a script. `--repo` is the same decision stated inline: the
resolved config must fall under the reference you give (an org,
`org/project`, or a pin), and on success it is recorded exactly like a yes.
`container create` seeds the policy with the project and revision you typed,
so the first connect does not prompt. `--dangerous` skips the check for one
invocation and records nothing.

```bash theme={"dark"}
tinfoil trust                             # show the policy
tinfoil trust set --mode frozen           # unknown configs fail instead of prompting
tinfoil trust set --record pin --prune    # record exact pins; drop broader entries
```

## Attestation Verification

### Verify Attestation

Use the `attestation verify` command to manually verify that an enclave is running the expected code:

```bash theme={"dark"}
tinfoil attestation verify \
  -e inference.tinfoil.sh \
  -r tinfoilsh/confidential-model-router
```

### JSON Output

You can also record the verification to a machine-readable audit log:

```bash theme={"dark"}
tinfoil attestation verify \
  -e inference.tinfoil.sh \
  -r tinfoilsh/confidential-model-router \
  -j > verification.json
```

Or use the `-l` flag to specify the output file directly:

```bash theme={"dark"}
tinfoil attestation verify \
  -e inference.tinfoil.sh \
  -r tinfoilsh/confidential-model-router \
  -j -l verification.json
```

The audit log record includes the timestamp, enclave host, repository reference, verified deployment artifact `digest`, code and enclave measurements, endorsed `crypto_material`, `freshness_expires_at`, and verification status.

### Command Options

* `-j, --json`: Output in JSON format
* `-l, --log-file`: Path to write the JSON log
* `-e, --enclave`: The hostname of the enclave. If omitted, auto-selects the default router.
* `-r, --repo`: Expected config as `owner/repo[@tag][@sha256:digest]` (or a registry reference `org/project[@revision][@sha256:digest]`; container commands also accept a bare `org`). Required for an explicit hostname; automatic router selection supplies its default repository. On container commands the assertion is recorded in your [connection policy](#connection-policy).

## Docker

A docker image is available at `ghcr.io/tinfoilsh/tinfoil-cli`.


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.