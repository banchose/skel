---
name: python
description: Modern Python 3.11+ coding standard — correctness-first principles, PEP 8/257, modern type-hint syntax (X | None, list[str]), ruff/uv/pytest tooling, pyproject.toml, PEP 723 single-file scripts, dataclasses, exception chaining, logging vs print, pathlib, subprocess, CLI entry points, security basics, and a list of non-Pythonic habits to avoid. Use when writing, reviewing, refactoring, or explaining Python code or scripts.
---

## Context
- **Target:** Python 3.11+ (use 3.10+ syntax freely: `X | Y`, `match`, parenthesised `with`). If the user names an older version, adapt.
- **Tools in this container:** `python3` 3.11, `ruff`, `uv`, `pytest`, `black`. No `mypy` — don't try to run it; say so if type-checking is wanted.
- **Mode:** Prefer stdlib. Produce complete, runnable code. Run `ruff check` and `ruff format --check` on anything you write when the file is on disk.

## Core principles (priority order)
1. **Correct** — it works and handles errors.
2. **Clear** — a human reads it without puzzling.
3. **Simple** — the straightforward path; no cleverness for its own sake.
4. **Pythonic** — use the language the way it was designed to be used.

When two rules conflict, the higher one wins.

## Style
- **PEP 8** naming: `snake_case` functions/variables/modules, `PascalCase` classes/exceptions, `UPPER_SNAKE` constants, leading `_` for internal.
- Line length 88, formatted by `ruff format` (Black-compatible). Don't hand-wrap differently.
- **PEP 257** docstrings: one-line summary, blank line, detail only if non-obvious. Document what the signature *doesn't* say (units, raises, side effects).
- Imports at the top, absolute, grouped stdlib / third-party / local with a blank line between (ruff `I` enforces). Never `from x import *`.
- f-strings for interpolation — **except in logging calls** (see Logging).
- Comments explain *why*, not *what*. No commented-out code.

## Type hints
- Annotate every function signature (params and return). `-> None` is explicit.
- Modern syntax only: `str | None`, `list[str]`, `dict[str, int]`, `tuple[int, ...]`. **Not** `Optional`, `Union`, `List`, `Dict`.
- Abstract containers from `collections.abc`: `Iterable`, `Iterator`, `Sequence`, `Mapping`, `Callable`. Accept the abstract type, return the concrete one.
- `from typing import` only for things that live there: `Any`, `Literal`, `Protocol`, `TypedDict`, `TypeVar`, `Self`, `TYPE_CHECKING`.
- `Any` is a last resort; say why in a comment if used.
- Don't annotate obvious locals (`count = 0`). Do annotate empty containers (`names: list[str] = []`).

## Data
- `@dataclass(frozen=True, slots=True)` for structured records instead of dicts or tuples. `kw_only=True` when there are more than ~3 fields.
- `field(default_factory=list)` for mutable defaults — never `= []`.
- `Enum` / `StrEnum` for a fixed set of choices; `Literal[...]` when it's just a type constraint.
- `NamedTuple` only if tuple-unpacking is the point.
- Dicts are for genuinely dynamic keys. If the keys are known, it's a dataclass or `TypedDict`.

## Errors
- Catch **specific** exceptions. Never bare `except:`; `except Exception` only at the outermost boundary (`main()`, request handler, worker loop).
- Don't catch what you can't handle — let it propagate to the boundary that logs once.
- Translate low-level errors into domain errors with the chain preserved: `raise ConfigError(...) from exc`.
- Validate at function boundaries, fail early, with a message that says what was wrong and what was expected: `raise ValueError(f"port must be 1-65535, got {port}")`.
- Built-in types first (`ValueError`, `TypeError`, `KeyError`, `FileNotFoundError`, `RuntimeError`). Define a custom hierarchy only when callers need to distinguish — one base class per package, specific subclasses under it.
- EAFP over LBYL when it reads as well: `try: v = d[k] except KeyError:` rather than `if k in d: v = d[k]`.
- Context managers (`with`) for every resource: files, locks, sockets, DB connections, temp dirs. `@contextlib.contextmanager` beats a hand-written `try/finally`.
- `assert` is for invariants during development, never for input validation (stripped by `-O`).

## Logging vs print
- `print()` is for a program's **actual output** to stdout (CLI results, pipes).
- `logging` is for **diagnostics** (progress, warnings, debug) — goes to stderr by default.
- Module level: `log = logging.getLogger(__name__)`. Configure (`basicConfig`) **only** in the entry point, never in importable modules.
- Lazy args, not f-strings: `log.info("processed %s in %.1fs", name, dt)` — the string is only built if the level is enabled (ruff `G004`).
- In an `except` block use `log.exception("...")` — ERROR plus traceback. `log.error(str(exc))` throws the stack away.
- Never log secrets.

## Files, paths, processes, time
- `pathlib.Path` everywhere; never `os.path` string juggling. `Path.read_text()` / `write_text()` for whole files.
- Always `encoding="utf-8"` on text opens — the default is platform-dependent.
- Atomic writes: write to a temp file in the same directory, then `tmp.replace(target)`.
- `subprocess.run([...], check=True, capture_output=True, text=True)`. Args as a list. `shell=True` only with a justified comment and no user-controlled input.
- Timezone-aware datetimes: `datetime.now(UTC)` (3.11: `from datetime import UTC`). Naive datetimes are a bug waiting to happen.
- `tempfile` for scratch files, never hard-coded `/tmp/foo`.

## Structure
- One module, one concern. Functions short and single-purpose — if the docstring needs "and", split it.
- Max ~3 levels of indentation. Past that: early return, extract a function, or invert the condition.
- No classes when a function will do. No inheritance when composition will do. No abstraction until there's a second concrete use.
- No premature optimisation. Measure first (`timeit`, `cProfile`).
- No mutable default arguments. No single-letter names outside comprehensions, lambdas, and loop indices. No module-level mutable state.
- Idioms over mechanics: `enumerate`, `zip(strict=True)`, `for … else` sparingly, comprehensions when they fit on a line or two, `any()`/`all()`, `dict.get(k, default)`, unpacking. `is None`, not `== None`. `if not items`, not `if len(items) == 0`.
- `match` when dispatching on structure (tags, shapes, nested data); `if/elif` for plain comparisons.
- Generators / `Iterator[T]` for large or streaming data instead of building lists.

## Scripts and CLI entry points
```python
"""One-line description of what this script does."""

import argparse
import logging
import sys

log = logging.getLogger(__name__)


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", help="file to process")
    parser.add_argument("-v", "--verbose", action="store_true")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO)
    log.info("processing %s", args.path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
```
- `main()` returns an int; `sys.exit(main())`. Keeps it testable and gives a real exit code.
- `argparse` from the stdlib. Reach for `click`/`typer` only when the user already uses them.
- **Single-file script with dependencies → PEP 723 inline metadata**, run with `uv run script.py`:
```python
# /// script
# requires-python = ">=3.11"
# dependencies = ["httpx>=0.27", "rich"]
# ///
```

## Projects and tooling
- `pyproject.toml` is the single config file (metadata, deps, ruff, pytest). No `setup.py`, `requirements.txt`, `.flake8`, `pytest.ini`. Template: `references/pyproject.toml`.
- `uv` for everything: `uv init`, `uv add pkg`, `uv add --dev pytest ruff`, `uv sync`, `uv run pytest`. Not `pip install` into the system interpreter.
- `ruff check --fix .` and `ruff format .` — replaces flake8, isort, black, pyupgrade, bandit. Recommended `select`: `E F I UP B SIM RUF PTH C4 G`.
- `src/` layout for packages: `src/<pkg>/__init__.py`.
- Lockfile (`uv.lock`) is committed for applications, not libraries.
- When you state a dependency: package name **and** the install line (`uv add httpx` / `pip install httpx`).

## Testing
- `pytest`, plain `assert`, no `unittest` classes.
- `@pytest.mark.parametrize` instead of loops in tests. `tmp_path` fixture instead of hand-made temp dirs. `monkeypatch` for env vars and attributes.
- Test names say what is expected: `test_parse_rejects_negative_port`.
- `pytest.raises(ValueError, match="port")` — check the message, not just the type.
- Keep logic out of `main()` so it can be tested without a subprocess.

## Security basics
- No `eval`/`exec` on anything external. No `pickle` from untrusted sources. `yaml.safe_load`, never `yaml.load`.
- `secrets` for tokens, not `random`. Compare secrets with `hmac.compare_digest`.
- Secrets from env or a secrets manager, never in code or logs.
- `subprocess` with list args; see above.

## When producing code
- Module docstring stating what the file does; brief docstring on every public function.
- Complete, runnable code — no placeholders, no `...` bodies, no "rest unchanged".
- Stdlib before third-party. If a third-party package is needed, name it and give the install command.
- If the file exists on disk, run `ruff check` and `ruff format --check` on it and fix what they flag.

## When explaining or reviewing
- Say *why* a choice was made, not just what the code does.
- If the user's code is non-Pythonic, show the idiomatic alternative and the one-sentence reason.
- Mention the common mistake related to the topic if there is one (mutable defaults, bare except, naive datetimes, missing encoding, f-strings in logging, `==` None).
- Review order follows the principles: correctness bugs first, then clarity, then simplicity, then style. Don't lead with style nits.
