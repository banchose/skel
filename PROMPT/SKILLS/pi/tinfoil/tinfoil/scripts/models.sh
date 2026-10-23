#!/usr/bin/env bash
# Fetch Tinfoil's /v1/models over a verified (attested, EHBP-encrypted) connection
# using the JS SDK bundled with the Pi tinfoil extension. Prints JSON to stdout.
# Requires TINFOIL_API_KEY in the environment. Never echoes the key.
set -euo pipefail

ext_dir="${TINFOIL_EXT_DIR:-$HOME/.pi/agent/extensions/tinfoil}"
[[ -n "${TINFOIL_API_KEY:-}" ]] || { echo "TINFOIL_API_KEY not set" >&2; exit 1; }
[[ -d "$ext_dir/node_modules/tinfoil" ]] || { echo "tinfoil SDK not found under $ext_dir" >&2; exit 1; }

# Script must live inside ext_dir so Node resolves 'tinfoil' from its node_modules.
probe="$ext_dir/_probe-models.$$.mjs"
trap 'rm -f "$probe"' EXIT
cat > "$probe" <<'EOF'
import { SecureClient } from "tinfoil";
const c = new SecureClient();
await c.ready();
const base = c.getBaseURL().replace(/\/$/, "");
console.error(`baseURL: ${base}`);
const r = await c.fetch(`${base}/models`, {
  headers: { Authorization: `Bearer ${process.env.TINFOIL_API_KEY}` },
});
if (!r.ok) { console.error(`HTTP ${r.status}`); process.exit(2); }
console.log(JSON.stringify(await r.json(), null, 2));
EOF
node "$probe"
