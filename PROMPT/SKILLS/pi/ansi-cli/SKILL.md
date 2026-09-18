---
name: ansi-cli
description: Writing terminal output that doesn't look broken — ANSI escape codes, color-depth and NO_COLOR detection, why ANSI 16 lies, progress bars, CLI flag/exit-code/stderr conventions, TUI framework picks. Use when writing or reviewing a CLI or TUI, colorizing output, adding a progress bar or spinner, or debugging garbled/invisible terminal output.
---

# ANSI & CLI output

Condensed from https://ansi.md (Adam Doppelt). Opinionated, targets terminals as of 2026 — not a VT100 conformance spec.

## Escape codes

All sequences start with ESC = `\e` = `\033` = `\x1b`. `\e[` is the CSI.
`{n}` = ANSI-16 index 0-7 (black, red, green, yellow, blue, magenta, cyan, white).
`{256}` = 0-255. `{RR};{GG};{BB}` = decimal channels (`#663399` → `102;51;153`).

| what | code |
|---|---|
| fg / bg ANSI 16 | `\e[3{n}m` / `\e[4{n}m` |
| fg / bg ANSI 16 bright | `\e[9{n}m` / `\e[10{n}m` |
| fg / bg ANSI 256 | `\e[38;5;{256}m` / `\e[48;5;{256}m` |
| fg / bg truecolor | `\e[38;2;{RR};{GG};{BB}m` / `\e[48;2;{RR};{GG};{BB}m` |
| bold | `\e[1m` |
| unset fg / bg | `\e[39m` / `\e[49m` |
| reset all | `\e[0m` |
| hide / show cursor | `\e[?25l` / `\e[?25h` |
| move cursor | `\e[{row};{col}H` |
| clear screen / + scrollback | `\e[2J` / `\e[3J` |
| window title | `\e]2;{title}\e\\` |
| hyperlink | `\e]8;;{url}\e\\{anchor}\e]8;;\e\\` |

Combine with semicolons: `printf '\e[1;31;42m hello \e[0m'`.
Always emit the reset — an unterminated sequence bleeds into the user's shell.

## Color: three rules

1. **Avoid ANSI 16, and 256 indices 0-15.** The user's theme remaps them. Asking for
   "white" gets you whatever Catppuccin decided white is, so white-on-green can come out
   unreadable. `\e[38;5;255;48;5;40m` (256 indices ≥16) is stable; `\e[37;42m` is a coin flip.
2. **256 (indices 16-255) is enough for most apps.** Truecolor is fine too, but prefer a
   library that downsamples for laggard terminals. Naive euclidean RGB→256 distance ignores
   human vision; use a perceptual metric if quality matters.
3. **Leave the background alone** except for deliberate emphasis (headers, banners) —
   inverted true-white-on-saturated is the safe attention-getter.

256 cube: indices 16-231 are `r,g,b` from `[0x00,0x5f,0x87,0xaf,0xd7,0xff]` at
`off=i-16`, `r=cube[off/36%6] g=cube[off/6%6] b=cube[off%6]`; 232-255 are grays `8+(i-232)*10`.

## Should color be on at all?

Precedence: `--flags` > env > `is_tty` default.

- stdout not a tty → default off (piped/redirected). Display-oriented apps may keep it on deliberately.
- Honor `NO_COLOR` and `FORCE_COLOR`. Ignore `CLICOLOR` / `CLICOLOR_FORCE` — barely used, all edge cases.
- `--color`/`--no-color` flags optional; skip for fun display apps.

How many colors: `COLORTERM=truecolor` is the cheap check, but it gets lost through `ssh`
and `tmux`. Fall back to sniffing `TERM` for known names, then terminfo. In practice every
popular terminal does 256; assume 256 and wait for a complaint before doing more.

Dark or light background: put the fd in raw mode, OSC 11 query, compute luma. Fiddly and
can hang on terminals that don't answer — timeout it, and default to dark.

## CLI conventions

| flag | behavior |
|---|---|
| `-h, --help` | help to **stdout**, exit 0 (also per-subcommand) |
| `-v, --version` | version, exit 0 (`-v` is *not* verbose) |
| `-f, --force` | override safeguards |
| `-q, --quiet` | no output |
| `--dry-run` | preview only |
| `--json` | JSON only |

- stdout is for output, stderr is only for errors. Exit 0 success, 1 failure. Bad flag → stderr + exit 1.
- Naked invocation (no args): print a one-line hint and exit **0**. Non-zero for "you gave me nothing" is unfriendly. Exception: if the app reads stdin, read stdin.
- Fail fast, fail loud. Never silently no-op on misconfiguration.
- Don't prompt except for destructive actions, and give `--force`/`--yes`.
- Errors name the thing: `/tmp/x.txt not found`, not `file not found`. `--bogus is not a valid flag`, not `invalid arg`.
- Config precedence: `--flag` > env > config file. Use XDG dirs; never write into `$HOME` directly.
- Verbosity/cache/retry knobs belong in env vars (`MYAPP_DEBUG=1`) — no `--help`, man page, or completion burden.

## Progress bars & spinners

Anything over ~1s deserves one. Mechanism: print a line with no newline, `\r`, repeat.
Hide the cursor (`\e[?25l`) while running and **restore it in a signal/exit handler** —
a killed app leaves the user with no cursor. Worth having: ETA that becomes elapsed-time on
completion, `17/33` counters, custom title. Percent matters less than people think.
Use a library (rich, indicatif, etc.); this is solved.

## TUI

Frameworks worth using: **bubbletea** (go, model/update/view + lipgloss), **ratatui**
(rust, immediate mode), **textual** (python, css-like), **ink**/**opentui** (ts, react +
flexbox). Prefer go/rust for anything complex.

The bottleneck is bytes to the terminal, not layout — a renderer that hits thousands of fps
into `/dev/null` gets ~25 fps in a real terminal. bubbletea/ratatui/opentui rebuild each
frame and diff against the previous one, emitting only the deltas. Do the same if you
hand-roll: never repaint a full frame per tick.

## Unwedging a terminal

`stty sane`, then `reset` (also resets scrollback), or the terminal's own Reset command.
`clear`/`reset`/`tput` just look escape strings up in terminfo and echo them. terminfo
itself is mostly irrelevant now — modern terminals share a common ANSI subset.

## Banner helper (sh)

```sh
GREEN="64;160;43"; YELLOW="251;100;11"; RED="210;15;57"
banner() { printf "\e[1;38;5;231;48;2;%sm[%s] %-72s \e[0m\n" "${2:-$GREEN}" "$(date '+%H:%M:%S')" "$1"; }
warning() { banner "$1" "$YELLOW"; }
fatal() { banner "$1" "$RED"; exit 1; }
```
