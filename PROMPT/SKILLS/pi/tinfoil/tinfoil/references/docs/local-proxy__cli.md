> ## Documentation Index
> Fetch the complete documentation index at: https://docs.tinfoil.sh/llms.txt
> Use this file to discover all available pages before exploring further.

# Tinfoil Proxy CLI

> Standalone command-line proxy that verifies enclave attestations and forwards OpenAI-compatible traffic to a Tinfoil enclave.

> **[View on GitHub](https://github.com/tinfoilsh/tinfoil-proxy)**
>
> tinfoilsh/tinfoil-proxy

`tinfoil-proxy` is a small Go binary that serves the same `http://127.0.0.1:3301/v1` endpoint as the menu-bar app. It's the right pick for scripts, CI runners, headless servers, or any workflow where you don't want a GUI.

> [!NOTE]
>
> Proxy versions that use V3 attestation have [beta verification](/resources/feature-status.md) while V3 deployment is ongoing.

### Install script (macOS & Linux)

```bash theme={"dark"}
curl -fsSL https://github.com/tinfoilsh/tinfoil-proxy/raw/main/install.sh | sh
```

This detects your OS and CPU architecture, downloads the matching `tinfoil-proxy` binary from the latest release, and installs it to `/usr/local/bin`. Set `INSTALL_DIR` to install elsewhere, or `VERSION` (e.g. `VERSION=0.0.8`) to pin a specific release.

### Pre-built binaries

Each release publishes standalone `tinfoil-proxy` binaries for macOS, Linux, and Windows alongside the desktop app installers. Grab the one for your OS from the [releases page](https://github.com/tinfoilsh/tinfoil-proxy/releases/latest).

### From source

```bash theme={"dark"}
go install github.com/tinfoilsh/tinfoil-proxy@latest
```

This drops `tinfoil-proxy` into `$GOPATH/bin` (usually `$HOME/go/bin`). Make sure that's on your `PATH`.

### Docker

A multi-arch image (linux/amd64 + arm64) is published to the GitHub Container Registry on every release:

```bash theme={"dark"}
docker run --rm -p 127.0.0.1:3301:3301 ghcr.io/tinfoilsh/tinfoil-proxy
# clients now use http://127.0.0.1:3301/v1
```

The image binds to `0.0.0.0` inside the container so the published port is reachable; mapping it to `127.0.0.1` on the host keeps the endpoint loopback-only. Append flags after the image name to override defaults, for example `ghcr.io/tinfoilsh/tinfoil-proxy -p 9443 -r tinfoilsh/confidential-model-router -e inference.tinfoil.sh`. Pin a specific version with the `:0.1.0` tag instead of `:latest`.

## Run it

```bash theme={"dark"}
tinfoil-proxy
```

The defaults are sensible: `tinfoil-proxy` listens on `http://127.0.0.1:3301` and auto-selects a Tinfoil router enclave, verifies its attestation against the public transparency log, and pins the attested public-key fingerprint for upstream TLS connections. If the enclave rotates its TLS certificate later, the proxy re-runs attestation before trusting the new key. Point any OpenAI-compatible client at:

```text theme={"dark"}
Base URL: http://127.0.0.1:3301/v1
```

### Pin a specific enclave

Leave `--host` and `--repo` unset for auto-discovery. To pin an enclave and its config repo, set both flags; setting only one is an error:

```bash theme={"dark"}
tinfoil-proxy \
  -r tinfoilsh/confidential-model-router \
  -e inference.tinfoil.sh \
  -p 3301
```

### Choose a custom port

```bash theme={"dark"}
tinfoil-proxy -p 9443
# clients now use http://127.0.0.1:9443/v1
```

## Command options

| Flag | Description | Default |
| - | - | - |
| `-p, --port` | Port to listen on | `3301` |
| `-b, --bind` | Address to bind to | `127.0.0.1` |
| `-e, --host` | Pin a specific enclave hostname | auto |
| `-r, --repo` | Pin a specific config repo | auto |
| `--allowed-host` | Additional `Host` header hostname to accept, such as a reverse proxy's public hostname (repeatable) | none |
| `--user-cache-secret` | Secret that scopes [prompt caching](/sdk/prompt-caching.md) for forwarded requests | generated and persisted |
| `--log-format` | `text` or `json` | `text` |
| `-v, --verbose` | Verbose output | off |
| `-t, --trace` | Trace output | off |

## Use it from any tool

Once `tinfoil-proxy` is running, the local endpoint is just a regular OpenAI-compatible base URL. See the [coding agents tutorial](/tutorials/coding-agents.md) for plug-and-play setups for Cline, Factory Droid, OpenCode, Hermes, and more.

## Compare to the menu-bar app

`tinfoil-proxy` (CLI) and [Tinfoil Proxy](/local-proxy/app.md) (menu-bar app) ship from the same repo. Both expose the same local endpoint (`http://127.0.0.1:3301/v1` by default) and run identical attestation against the Tinfoil router enclave they forward to upstream. Pick whichever fits your workflow:

| | CLI (`tinfoil-proxy`) | Menu-bar app (Tinfoil Proxy) |
| - | - | - |
| Best for | Scripts, CI, headless servers | Day-to-day use on your laptop |
| Install | `go install …` or pre-built binary | `.pkg` / `.deb` / `.exe` |
| Stays running | Foreground process | Menu-bar (opt in to **Open at Login**) |
| Auto-update | Manual | Built in (macOS & Windows) |
| Verification UI | Logs | Live status |


This documentation is built and hosted on [Mintlify](https://mintlify.com), a developer documentation platform.