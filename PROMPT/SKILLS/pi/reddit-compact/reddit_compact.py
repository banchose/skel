"""Collapse a copy-pasted Reddit comment page into one line per comment.

Input is the plain text you get by select-all / copy on a new-Reddit post
page and pasting into a file. Each comment there is wrapped in ~10 lines of
UI chrome (Upvote / Downvote / Reply / Award / Share ...). This script keeps
the content and drops the chrome:

    [score] user (age): body text
    second body paragraph...

Lines it cannot parse are emitted with a ``## `` prefix so format drift is
visible instead of silently losing text. Thread nesting is not recoverable
from the pasted text, so it is not attempted.
"""

import argparse
import logging
import re
import sys
from collections.abc import Iterator
from dataclasses import dataclass
from pathlib import Path

log = logging.getLogger(__name__)

AGE_RE = re.compile(r"^\d+[hmd] ago$|^just now$")
EDITED_RE = re.compile(r"^• Edited ")
MORE_REPLIES_RE = re.compile(r"^((?P<count>\d+) more repl(y|ies)|More replies)$")
PAGE_TITLE_RE = re.compile(r"^(?P<title>.+) : (?P<sub>r/\w+)$")
COMMENT_MARKERS = {"•", "OP •"}
CHROME = {"Upvote", "Downvote", "Reply", "Award", "Share"}
NOISE_PREFIXES = ("Profile Badge for the Achievement",)
NOISE_SUFFIXES = (" avatar",)
NOISE_LINES = {"View more comments"}
REMOVED_MARKER = "Comment has been removed"
COMMENTS_START = "Comments Section"
MIN_SUMMARY_LEN = 80  # shorter "longest line" is header chrome, not selftext
NO_SCORE = "-"


@dataclass(frozen=True, slots=True)
class Comment:
    """One parsed comment. ``score`` is Reddit's display string, e.g. '2.9K'."""

    user: str
    age: str
    score: str
    body: str
    is_op: bool = False

    @property
    def score_value(self) -> float:
        """Numeric score for sorting; hidden/missing scores sort last."""
        return parse_score(self.score)

    def format(self) -> str:
        tag = " [OP]" if self.is_op else ""
        age = f" ({self.age})" if self.age else ""
        return f"[{self.score}] {self.user}{tag}{age}: {self.body}"


def parse_score(text: str) -> float:
    """Convert '13K', '1.7K', '42', '-3', 'Vote' to a number."""
    if text == NO_SCORE:
        return float("-inf")
    multiplier = 1.0
    if text.endswith(("K", "k")):
        multiplier = 1000.0
        text = text[:-1]
    try:
        return float(text) * multiplier
    except ValueError:
        return float("-inf")


def is_noise(line: str) -> bool:
    return (
        not line.strip()
        or line.startswith(NOISE_PREFIXES)
        or line.endswith(NOISE_SUFFIXES)
        or line in NOISE_LINES
        or bool(MORE_REPLIES_RE.match(line))
    )


def clean_body(lines: list[str]) -> str:
    kept = [ln.rstrip() for ln in lines if not is_noise(ln)]
    return "\n".join(kept).strip()


def parse_header(lines: list[str]) -> list[str]:
    """Best-effort extraction of post title, subreddit, poster, score, summary."""
    title = sub = poster = score = ""
    longest = ""
    for i, line in enumerate(lines):
        if is_noise(line):
            continue
        if m := PAGE_TITLE_RE.match(line):
            title, sub = title or m["title"], sub or m["sub"]
        elif line.startswith("u/") and " " not in line:
            poster = poster or line
        elif line == "Upvote" and i + 1 < len(lines) and not score:
            score = lines[i + 1]
        elif len(line) > len(longest) and line != title:
            longest = line
    out: list[str] = []
    if title:
        out.append(f"# {title}")
    meta = " · ".join(x for x in (sub, poster, f"{score} upvotes" if score else ""))
    if meta:
        out.append(f"# {meta}")
    if len(longest) >= MIN_SUMMARY_LEN and longest != title:
        out.append(f"# {longest}")
    return out


def _skip_chrome(lines: list[str], i: int) -> int:
    """Advance past Downvote / Reply / <reply count> / Award / Share."""
    while i < len(lines):
        line = lines[i]
        after_reply = i > 0 and lines[i - 1] == "Reply"
        if line in CHROME or (after_reply and line.isdigit()):
            i += 1
        else:
            break
    return i


def _is_comment_start(lines: list[str], i: int) -> bool:
    """True if lines[i:i+3] look like ``user / • / 6h ago``."""
    return (
        i + 2 < len(lines)
        and lines[i + 1] in COMMENT_MARKERS
        and bool(AGE_RE.match(lines[i + 2]))
    )


def _read_score(lines: list[str], i: int) -> tuple[str, int]:
    """Read the score after an ``Upvote`` line at ``i``; return (score, next index)."""
    j = i + 1
    if j >= len(lines) or lines[j] in CHROME:
        return NO_SCORE, j
    score = lines[j]
    if score == "Vote":  # Reddit hides the score on fresh comments
        score = "0"
    return score, j + 1


def parse_comments(lines: list[str]) -> Iterator[Comment | str]:
    """Yield Comment objects, or raw strings for lines that did not parse.

    A comment body runs until the next ``Upvote`` line *or* the next
    comment-start triple, whichever comes first. The second case covers pastes
    where Reddit had not rendered the vote buttons for some comments; those get
    ``NO_SCORE`` rather than swallowing their neighbours.
    """
    i, n = 0, len(lines)
    while i < n:
        if _is_comment_start(lines, i):
            user, is_op, age = lines[i], lines[i + 1] == "OP •", lines[i + 2]
            j = i + 3
            if j < n and EDITED_RE.match(lines[j]):
                j += 1
            body_start = j
            while j < n and lines[j] != "Upvote" and not _is_comment_start(lines, j):
                j += 1
            body = clean_body(lines[body_start:j])
            if j < n and lines[j] == "Upvote":
                score, j = _read_score(lines, j)
                j = _skip_chrome(lines, j)
            else:
                score = NO_SCORE
            yield Comment(user, age, score, body, is_op)
            i = j
        elif lines[i] == "[deleted]" and i + 2 < n and lines[i + 2] == REMOVED_MARKER:
            yield Comment("[deleted]", "", NO_SCORE, "(comment removed)")
            i = _skip_chrome(lines, i + 3)
        else:
            if not is_noise(lines[i]):
                yield lines[i]
            i += 1


def split_sections(text: str) -> tuple[list[str], list[str]]:
    """Return (header lines, comment lines) split at the comments marker."""
    lines = text.split("\n")
    try:
        start = lines.index(COMMENTS_START)
    except ValueError:
        log.warning("no %r line found; treating whole file as comments", COMMENTS_START)
        return [], lines
    return lines[:start], lines[start + 1 :]


def count_collapsed(lines: list[str]) -> tuple[int, int]:
    """Return (collapsed thread markers, replies hidden behind them).

    ``More replies`` without a number counts as at least 1 hidden reply.
    """
    markers = hidden = 0
    for line in lines:
        if m := MORE_REPLIES_RE.match(line):
            markers += 1
            hidden += int(m["count"]) if m["count"] else 1
    return markers, hidden


def compact(text: str, top: int | None = None, sort: bool = False) -> str:
    header, comment_lines = split_sections(text)
    markers, hidden = count_collapsed(comment_lines)
    comments: list[Comment] = []
    unparsed: list[str] = []
    for item in parse_comments(comment_lines):
        if isinstance(item, Comment):
            comments.append(item)
        else:
            unparsed.append(item)

    if sort or top is not None:
        comments.sort(key=lambda c: c.score_value, reverse=True)
    if top is not None:
        comments = comments[:top]

    out = parse_header(header)
    out.extend(c.format() for c in comments)
    out.extend(f"## {line}" for line in unparsed)

    log.info("parsed %d comments, %d unparsed lines", len(comments), len(unparsed))
    if markers:
        log.info(
            "%d collapsed threads in the dump; at least %d replies are not included",
            markers,
            hidden,
        )
    if unparsed:
        log.warning("unparsed lines are at the end of the output, prefixed '## '")
    return "\n".join(out) + "\n"


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__.split("\n", 1)[0])
    parser.add_argument("path", type=Path, help="pasted Reddit page text")
    parser.add_argument(
        "-o", "--output", type=Path, help="write here instead of stdout"
    )
    parser.add_argument(
        "--top", type=int, metavar="N", help="keep only N highest-scored"
    )
    parser.add_argument("--sort", action="store_true", help="sort all by score")
    parser.add_argument("-v", "--verbose", action="store_true")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO, format="%(message)s"
    )
    if args.top is not None and args.top < 1:
        log.error("--top must be >= 1, got %d", args.top)
        return 2
    try:
        text = args.path.read_text(encoding="utf-8")
    except OSError as exc:
        log.error("cannot read %s: %s", args.path, exc)
        return 1

    result = compact(text, top=args.top, sort=args.sort)
    if args.output:
        args.output.write_text(result, encoding="utf-8")
        log.info("wrote %s", args.output)
    else:
        sys.stdout.write(result)
    return 0


if __name__ == "__main__":
    sys.exit(main())
