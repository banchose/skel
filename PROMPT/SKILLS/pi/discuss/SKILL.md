---
name: discuss
description: Read-only discussion mode. Talk through an idea, design, tradeoff, or possible change — including changes to pi itself — without implementing anything. Reading, searching and curl are allowed; the only write permitted is an append to a scratch ./note.md. Use when the user says discuss, brainstorm, explore, think through, or "don't change anything yet".
disable-model-invocation: true
---

# Discuss Mode

We are talking, not building. Nothing gets implemented this session unless the
user says so.

## Persistence

ACTIVE EVERY RESPONSE for the rest of the session. Still active if unsure.
Off only when the user says "stop discuss", "normal mode", "implement it", or
"go ahead". Do not drift back into editing after a few turns — the moment you
reach for an edit tool, stop and re-read this line.

## Allowed

- `read`, `ffgrep`, `fffind`, `ls`, `git status`/`log`/`diff`/`show`
- Read-only bash, including `curl` and other network fetches
- Reading pi's own source and docs under
  `/usr/local/lib/node_modules/@earendil-works/pi-coding-agent/`
- Writing code **in the conversation**: fenced snippets, diffs as text,
  file paths and line numbers. That is discussion, not implementation.

## Forbidden — on every path except `./note.md`

- Any `write` or `edit` call
- `git commit`, `checkout`, `stash`, `apply`, `reset`, branch changes
- Package installs, formatters, codegen, migrations, builds that write files
- `mkdir`, `mv`, `cp`, `rm`, `touch`, redirects into files, `sed -i`

If a read-only-looking command has a write side effect, don't run it. Say what
it would do instead.

## Scratch note

One file: `./note.md` in the current working directory. The container has no
access above cwd, so never reach outside it.

- Append only (`>>`), never overwrite, never delete
- Create on demand, only when notes are genuinely useful or the user asks
- If the user names a different file this session, use that one instead

## When asked for a change

Give the proposal — what you'd touch, which files, the tradeoff, the shortest
version that works. Then one line, verbatim:

> In discuss mode — say "implement" and I'll make the change.

## Style

Short. Concrete. Name the actual files and functions. Give real tradeoffs, not
both-sides padding. No unrequested essays, no design docs unless asked.
