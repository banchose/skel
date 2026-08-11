## Add shellcheck to the Pi Dockerfile (static binary only)

### Summary
Add the upstream static shellcheck binary to `/workspace/Dockerfile` at `/usr/local/bin/shellcheck`, following the existing jq pattern. Purpose is tooling for Pi to lint shell scripts, so no apt package and no man page. Base image is `node:24-bookworm-slim` (Debian), so snap never enters the picture; the static binary avoids both snap and the Haskell/cabal toolchain.

### Changes

1. **Existing first `apt-get install` list** (the `bash ca-certificates git ripgrep ...` line): add `xz-utils` only.
   - The upstream release is `.tar.xz`; `tar -J` needs the `xz` binary, which bookworm-slim / node-slim does not guarantee is present.
   - Nothing else changes in the apt blocks; `mandb -c` is untouched.

2. **New `RUN` block immediately after the existing jq block** (grouped with the other pinned `/usr/local/bin` binaries, before `npm install -g`):
   - `ARG SHELLCHECK_VERSION=0.11.0`
   - `set -eux` + `curl -fsSL` of `https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz`, piped to `tar -xJ --strip-components=1 -C /usr/local/bin shellcheck-v${SHELLCHECK_VERSION}/shellcheck` so only the binary is extracted, then `chmod 0755 /usr/local/bin/shellcheck`.
   - One comment line stating why the binary is used instead of apt: apt ships 0.9.0 and only the linter is needed.

### Behavior / interface notes
- `shellcheck` becomes available on PATH for every user in the image, including the `node` user Pi runs as, and for `docker run --entrypoint shellcheck`.
- Version bumps are a one-token `ARG` edit, overridable via `--build-arg SHELLCHECK_VERSION=...`.
- No apt `shellcheck`, therefore no `man shellcheck`; `shellcheck --help` still works.
- Image grows by roughly the static binary (~7 MB) plus `xz-utils`.
- Layer ordering preserves the existing cache prefix; only the apt layer onward rebuilds.

### Verification
- `docker build -f Dockerfile -t pi-node-user-man .` succeeds.
- `docker run --rm --entrypoint sh pi-node-user-man -c 'command -v shellcheck && shellcheck --version'` → `/usr/local/bin/shellcheck`, version `0.11.0`.
- Real smoke test on repo scripts: `docker run --rm -v "$PWD:/workspace" --entrypoint shellcheck pi-node-user-man build-pi.sh run-pi-bed.sh run-pi-bed-root.sh pi-extensions.sh COPY-MCP-TO-PI-IMAGE.sh` → runs to completion; reported findings are expected and fine, a crash or "not found" is the failure.
- Exit-code check that Pi can rely on: a file with a known issue must exit non-zero, a clean file must exit 0.
- Negative build check: `--build-arg SHELLCHECK_VERSION=0.0.0` must fail the build (proves `curl -fsSL` is not silently producing an image without shellcheck).

### Assumptions and defaults
- **No checksum pinning**, per your choice: integrity rests on HTTPS to github.com. Add `ARG SHELLCHECK_SHA256` + `sha256sum -c -` later for parity with the jq block (shellcheck publishes no `sha256sum.txt`, so the digest has to be computed once by hand).
- **0.11.0 assumed current**; not verifiable from plan mode. Confirm the release tag while implementing and adjust the `ARG` if upstream has moved.
- **amd64 only**, matching the existing `jq-linux-amd64` pin. No arm64 branch until you build on Apple silicon.
- Skipped: apt package + man page, checksum verification, multi-arch selection, separate build stage. Add each only when the need is concrete.
