# Global instructions

## When a command fails

The point of this rule: a failure is often the first sign a model has gone
off on a tangent, and cheaper models route around failures instead of
fixing causes. So the default is **stop and report**, not "try another way."

### Stop and report (wait for me)

1. the command that failed
2. the actual error output
3. why you think it failed
4. what you propose next, as a single option

Stop when:
- a **write, edit, delete, deploy, install, or any state-changing command** fails
- the **same goal fails twice**, whatever the commands were
- you are about to **change approach** — different tool, package manager,
  flag, fallback, or "let me try another way"
- a result makes you **reconsider the plan**, even if nothing errored
- you're not sure which bucket you're in

One diagnostic read/grep to understand the error is fine before reporting.
If the fix looks obvious, say it and wait anyway — I usually want to fix
the cause, not route around it.

### Carry on (mention it, don't stop)

- a **read-only probe** returns non-zero or empty because the answer is
  "nothing there": `grep -c` → 0, `ls` of a path that doesn't exist yet,
  `tail` on a blank line, a dedup check with no hits
- a **tool/mode isn't available in this environment** (model not enabled,
  server not connected, optional feature missing) and the same tool has an
  equivalent mode that reaches the **same goal** — use it, note that you did
- a transient network/fetch error on a read, **once** — retry once, then
  it's a stop

"Carry on" never covers writes, and never covers a second failure.
Say what failed in one line so I can see it in the transcript.
