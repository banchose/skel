---
name: careful-operations-discipline
description: 'Two-speed operating discipline for technical work: batch reads and reversible edits to move fast, then downshift to one-at-a-time confirm-before-acting for irreversible operations. Discover values instead of assuming them, syntax-test complex commands on static input, and flag blast radius. Use when scripting, debugging, changing infrastructure or config, or running destructive or production commands.'
---
# Careful Operations Discipline

The cost of a mistake sets the cadence — not whether the operation is a write.

If following a rule here would be obviously counterproductive, deviate — but
say so and why. Unmarked deviation is not acceptable.

## 1. Discover, don't assume

Any value you don't have from this session — ID, ARN, path, endpoint, IP,
version, config key, table name — gets *fetched*, not recalled. Memory,
inference, and "that's the usual name" are not sources. If you're unsure a
known value is still current, re-read it.

This rule has no fast path. It applies to reads and writes equally.

## 2. Batch freely while reading

Read-only calls (get, list, describe, status, grep, cat) are cheap and safe.
Group them in one shot; don't drip-feed. Only serialize when one output feeds
the next.

Same for **reversible mutations**: files tracked by version control,
idempotent config writes, anything a `git checkout` or re-run undoes. Batch
them, then verify once at the end.

State what you're trying to learn before a batch — one line, so bad
assumptions get caught before they run.

## 3. Downshift for irreversible operations

Downshift when an operation cannot be cheaply undone:

- deletes, drops, truncates, overwrites of untracked files
- production traffic, live data, anything customer-facing
- security and access: IAM, keys, firewall, secrets, auth config
- schema migrations, data backfills
- service restarts where downtime matters
- anything with side effects outside this machine (emails, payments, webhooks)

In this mode:

- **One operation at a time.** Never bundled, never mixed with reads.
- **Confirm current state first** with a read, if not already confirmed in this
  exchange.
- **Say what it will do and what you expect after** — then ask for explicit
  confirmation before running it. Flag it: `⚠️ irreversible`.
- **Verify after**, and prefer a *functional* check over a config check: "can
  we reach the endpoint" beats "is the value set".
- For production or security changes, verify a second time from a different
  angle — different context, logs, or console.
- Don't proceed to the next step until verification passes.

Unsure which tier an operation is in? It's irreversible.

## 4. Syntax-test complex commands

`jq`, `awk`, `sed`, regex, nested quoting, multi-stage pipelines: run it
against small static input first, then against real data.

```bash
# [SYNTAX TEST] — does the filter parse and select correctly?
echo '{"Items":[{"id":"abc123","status":"active"}]}' \
  | jq '.Items[] | select(.status=="active") | .id'

# [LIVE]
aws dynamodb scan --table-name MyTable | jq '.Items[] | select(...)'
```

## 5. Flag blast radius in scripts

Present scripts and diffs for review before execution. Call out the lines that
mutate state, and for any loop that mutates, state the count: "this updates all
47 matching records." A number the user can sanity-check is worth more than a
paragraph of caveats.

## The two speeds

| Mode          | When                                      | Cadence                            |
|---------------|-------------------------------------------|------------------------------------|
| **Efficient** | Reads; reversible edits (VCS, idempotent) | Batch, move quickly, verify at end |
| **Careful**   | Irreversible, production, security, data  | One at a time, confirm, verify ×2  |

Default to efficient. Downshift on irreversibility, not on writes.
