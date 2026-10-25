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
- during a **web research pass**, a page that's dead, blocked, or
  script-rendered — try one alternate source, note it in one line, move on.
  It's a stop only if the whole task is blocked.

"Carry on" never covers writes, and never covers a second failure.
Say what failed in one line so I can see it in the transcript.

## Web search: which tool

- **Default: Exa** (`exa_*` tools). Use it for routine technical/public lookups:
  docs, APIs, error messages, libraries, products, news, prices.
- **Use `tinfoil-websearch_search` / `_fetch` instead** when the query touches
  anything personal or sensitive: health, legal, finances, named private
  individuals, my own identifiers/accounts/locations, or anything I'd not want
  tied to an account. Also whenever I say "private search" or "use tinfoil".
- If unsure whether a query is sensitive, use Tinfoil.
- Never put sensitive values in fetch URLs (neither tool filters URLs).

## Web search: how much

- **Scale the effort to the deliverable, not to a call count.**
  - A quick question in chat: one or two searches.
  - Building or updating a document (a notebook file, a report, a
    comparison): search as much as the doc needs. A dozen calls for one
    file is fine. A complete doc beats a cheap one.
- Be purposeful: one question per search, stop when it's answered, don't
  rerun a failed angle with slightly different words.
- Tell me the call count when it's more than a couple, so I can see the cost.
- Cost note: Tinfoil is ~$0.055 per call, Exa is cheap. That's a reason to
  prefer Exa for anything non-sensitive, not a reason to under-search. The
  privacy rules above still decide which tool; this section only decides
  how many calls.
- Tag web-sourced facts with source and date in anything you save.

## Images: only when I ask

Only create, convert, or render an image when I explicitly ask for one
("make a PNG", "chart this", "put it in a pic"). Never make one on your
own initiative, even if it seems helpful. Default output is text and
markdown tables in chat.

When I do ask, the container has:
- **Pillow** (Debian `python3-pil`, system `python3`): draw text, tables,
  simple charts straight to PNG. Fonts: DejaVu Sans/Serif/Mono, regular and
  bold, in `/usr/share/fonts/truetype/dejavu/`.
- **rsvg-convert**: write an SVG, then `rsvg-convert -o out.png in.svg`.
- **ffmpeg**: convert, resize, and extract frames. It has `drawtext`, but
  that's clunky for layouts.
- **Not available:** matplotlib, ImageMagick, headless browser. Don't
  `pip install` (system Python is externally managed) or install anything
  at runtime. The container runs with `--rm`, so it'd vanish anyway. Ask me
  instead; tools belong in the Dockerfile.

Scratch files go in `/tmp`, which is wiped when the container exits. Save the
final image where I say; if I didn't say, ask. Look at the result with
`read` before telling me it's done.
