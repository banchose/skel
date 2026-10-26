---
name: reddit-compact
description: Collapse a copy-pasted Reddit comment page (plain text dump with Upvote/Downvote/Reply/Share chrome) into one line per comment, optionally sorted or limited to the top N by score. Use when the user gives a Reddit thread saved as a .txt file and wants it summarized, cleaned, or analyzed — run the script first instead of reading the raw dump or re-deriving a parser.
---

# reddit-compact

Script: `reddit_compact.py` (same directory as this file; stdlib only, Python 3.11+).

## When to use

The user has a `.txt` file made by select-all / copy on a new-Reddit post page.
Tell-tale signs: lines like `Skip to main content`, repeated
`Upvote` / `Downvote` / `Reply` / `Award` / `Share`, `N more replies`,
`Profile Badge for the Achievement ...`, `u/name avatar`.

Run the script **before** reading the file. The raw dump is ~80% UI chrome;
the compact form is one comment per line and sortable by score.

## Usage

```bash
# full compact file (keeps original order, which is Reddit's "Best" sort)
python3 reddit_compact.py dump.txt -o dump-compact.txt

# top N by score to stdout — usually all you need to read for a summary
python3 reddit_compact.py dump.txt --top 120

# everything, sorted by score
python3 reddit_compact.py dump.txt --sort -o dump-sorted.txt
```

Flags: `-o PATH` write to file (default stdout), `--top N`, `--sort`, `-v`.
Progress goes to stderr, e.g.:

```
parsed 628 comments, 0 unparsed lines
94 collapsed threads in the dump; at least 641 replies are not included
```

The second line counts Reddit's `+` / `N more replies` markers the user did
not expand before copying. Those replies are **not in the file**. Mention the
ratio in any summary (here ~half the thread was hidden) — collapsed threads
are the deeper, lower-voted replies, so top-level sentiment is still reliable
but niche sub-discussions may be missing entirely.

## Output format

```
# <post title>
# r/sub · u/poster · 13K upvotes
# <link summary or selftext>
[2.9K] user (6h ago): first paragraph of comment
second paragraph of comment
[960] other_user [OP] (5h ago): ...
[-] [deleted]: (comment removed)
## <any line the parser could not place>
```

- `[score]` is Reddit's display string (`6K`, `1.7K`, `42`, `-3`, `0`).
  `[-]` means no score was captured: deleted/removed comments, or comments
  whose vote buttons hadn't rendered when the page was copied (this happens
  in real pastes — a run of 3+ consecutive `[-]` comments is that, not a bug).
- A comment ends at the next `Upvote` line **or** the next `user / • / age`
  triple, whichever comes first, so missing chrome never merges neighbours.
- An empty body after the colon is real: image/GIF-only comments paste as
  nothing.
- `[OP]` marks the original poster.
- Thread nesting is **not** recoverable from the pasted text; comments appear
  in page order. A reply usually directly follows the comment it answers,
  but don't assert parent/child relationships.

## Checking the result

- stderr reports `N unparsed lines`. If it is not 0, look at the `## ` lines
  at the end of the output. A handful usually means a new Reddit UI element;
  many means the page layout changed and the parser needs updating.
- Sanity check the count against the original. Expected =
  (number of `user / • / age` triples, minus 1 for the post header)
  + (number of `[deleted]` / `Comment has been removed` blocks). Quick version:
  `grep -cE '^(•|OP •)$' dump.txt` - 1 + `grep -c '^Comment has been removed$' dump.txt`.
  A `• Edited …` line does not match `^•$`, so no correction is needed for it.

## Summarizing a thread

Read `--top 100`–`150` (typically 20–25% of the file) for the consensus, then
`grep -ci` the compact file for themes the top comments may miss. Report
vote counts with the claims so the user can see what was consensus vs. fringe.

## Tested on

- r/news, 628 comments, logged-out, with Award/Share chrome and several
  comments missing vote chrome entirely (2026-10-26)
- r/nfl, 15 comments, no Award/Share lines, `More replies` without a count

## Workflow rules

- Never modify the user's original dump; write compact output to a new file.
- The script is also kept at `/workspace/reddit-compact/` — if both exist and
  differ, the user owns the workspace copy; ask before changing either.
