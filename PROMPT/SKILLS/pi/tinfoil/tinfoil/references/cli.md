# Tinfoil CLI (`tinfoil`)

Source: https://docs.tinfoil.sh/sdk/cli-sdk.md · repo `tinfoilsh/tinfoil-cli` ·
Docker `ghcr.io/tinfoilsh/tinfoil-cli`. **Not installed in the Pi container**
(as of 2026-10-23). Uses V3 attestation (beta).

## Install / update

```bash
curl -fsSL https://github.com/tinfoilsh/tinfoil-cli/raw/main/install.sh | sh   # uses sudo → /usr/local/bin
# or: download release binary; or: git clone … && go build -o tinfoil
tinfoil update              # self-update, verifies SHA-256; never sudo; refuses on Homebrew / dev builds
tinfoil update --check -o json   # {current_version, latest_version, status: available|up-to-date|installed}
TINFOIL_NO_UPDATE_CHECK=1   # silence the once-a-day passive notice
```

## Command families

| Family | Commands |
| --- | --- |
| Verification & connectivity | `attestation`, `proxy`, `http`, `forward`, `ssh`, `scp`, `attest-ssh` |
| Auth | `login`, `logout`, `whoami` |
| Container mgmt | `container`, `project`, `model`, `repo` |
| Org resources | `volume`, `secret`, `ssh-key`, `registry`, `domain` |
| Trust policy | `trust`, `trust set` |

`tinfoil <cmd> --help` for details.

## Verified HTTP

```bash
tinfoil http get https://inference.tinfoil.sh/health \
  -e inference.tinfoil.sh -r tinfoilsh/confidential-model-router

tinfoil http post https://inference.tinfoil.sh/v1/chat/completions \
  -e inference.tinfoil.sh -r tinfoilsh/confidential-model-router \
  -H "Authorization: Bearer $TINFOIL_API_KEY" -H "Content-Type: application/json" \
  -s \   # stream (POST only); needs "stream": true in body
  -b '{"model":"gpt-oss-120b","stream":true,"messages":[{"role":"user","content":"Hello"}]}'
```

Flags: `-b/--body`, `-H/--header` (repeatable), `-s/--stream`.
`-e/--enclave` hostname (omit ⇒ auto-select default router); `-r/--repo`
required when `-e` is explicit.

## Attestation verify

```bash
tinfoil attestation verify -e inference.tinfoil.sh -r tinfoilsh/confidential-model-router
tinfoil attestation verify … -j > verification.json      # or -j -l verification.json
```

JSON audit record: timestamp, enclave host, repo ref, deployment artifact
`digest`, code + enclave measurements, endorsed `crypto_material`,
`freshness_expires_at`, status. Freshness witness max age is 7 days (not
configurable).

## Pinning a release (`--repo`)

| Value | Constraint |
| --- | --- |
| `owner/workload` | any release with valid provenance + current freshness witness |
| `owner/workload@v1.2.3` | exact authenticated tag |
| `owner/workload@sha256:<64 hex>` | exact signed deployment artifact |
| `owner/workload@v1.2.3@sha256:<digest>` | both |

Also accepts registry refs `org/project[@revision][@sha256:…]`; container
commands accept a bare `org`.

## Connection policy (`~/.tinfoil/known-configs.yml`)

Governs `container connect`, `forward`, `ssh`, `scp`, `attest-ssh`.

```yaml
mode: prompt          # prompt | frozen (unknown configs fail)
record: project       # org | project | pin — granularity recorded on "yes"
allow:
  orgs: [myorg]
  projects: [myorg/my-api]
  pins: [myorg/my-api@v1.2.3@sha256:ab…]   # also the connect journal
```

- Unknown config ⇒ prompt in a TTY, **fail closed in scripts**.
- `--repo` inline = same decision; `--dangerous` skips check once, records nothing.
- `container create` seeds the policy so first connect doesn't prompt.
- `tinfoil trust` (show), `tinfoil trust set --mode frozen`,
  `tinfoil trust set --record pin --prune`.
