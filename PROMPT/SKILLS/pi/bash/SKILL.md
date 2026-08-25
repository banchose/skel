---
name: bash
description: Expert Bash 5+ scripting reference — safety rules (set -euo pipefail caveats, quoting, traps), functions, arrays, argument parsing, cleanup, dependency checks, /dev/tcp networking, SSH quoting, minimal-environment fallbacks, and common pitfalls. Use when writing, reviewing, or debugging bash/shell scripts.
---


## Context
- **Target:** Bash 5+
- **Mode:** Expert scripting — safety focus, prefer Bashisms over POSIX where cleaner
- **Defaults:** Functions over standalone scripts; all output must be shellcheck-clean

## Critical Safety Rules
- Quote **all** expansions: `"$var"` — use braces (`"${var}"`) when needed for disambiguation (`"${var}suffix"`, arrays, parameter expansion)
- Use `[[ ]]` over `[ ]` for conditionals
- Prefer `(( ))` for arithmetic — **but see the `set -e` interaction below**
- Always set `set -euo pipefail` unless explicit error handling replaces it
- Add `set -E` (`errtrace`) when using `trap ... ERR` — without it, ERR traps don't fire inside functions
- Set `shopt -s nullglob` (or `failglob`) in scripts that iterate over globs — otherwise an unmatched glob passes through as a literal string
- Shebang: `#!/usr/bin/env bash`

## `set -e` Caveats (know what it does NOT catch)
- Does **not** fire for commands in `if`/`while`/`until` conditions, or on the left of `&&`/`||`
- Does **not** propagate into command substitution in some contexts (e.g., `local var=$(cmd)` masks the exit status — declare and assign on separate lines)
- **Arithmetic gotcha:** `(( count++ ))` when `count=0` evaluates to 0 → exit status 1 → script dies under `set -e`
  - Safe forms: `(( count += 1 ))`, `count=$(( count + 1 ))`, or `(( count++ )) || true`
- `set -e` is a safety net, not error handling — still check critical commands explicitly

## Functions
- Always declare function variables with `local`
- Declare and assign separately when capturing output: `local out; out=$(cmd)` — combined form masks the exit status
- Return data via stdout (`result=$(fn)`) or a nameref (`declare -n`), not globals
- Use `local -a` / `local -A` for local arrays

## Command Substitution
- Modern syntax: `var=$(cmd)` — never backticks
- Always quote: `"$(cmd)"` to prevent word splitting/globbing
- Read file into var: `var=$(<file)` — faster than `$(cat file)`

## File Reading
- Standard loop: `while IFS= read -r line || [[ -n "$line" ]]; do ...; done`
- Always use `-r` (prevents backslash interpretation)
- Field splitting: `IFS=':' read -r f1 f2 rest`
- Input sources: `< file`, `<<< "$var"`, `< <(cmd)` (process substitution avoids subshell)
- **Never:** `for line in $(cat file)` — breaks on whitespace

## Data Structures
- Associative arrays: `declare -A map`
- Access: `"${map[key]}"` — keys: `"${!map[@]}"`
- **Never** use `eval` with untrusted input

## Output Capture
| Target         | Pattern                          |
|----------------|----------------------------------|
| stdout         | `out=$(cmd)`                     |
| stderr only    | `err=$(cmd 2>&1 >/dev/null)`     |
| both           | `out=$(cmd 2>&1)`                |
| exit status    | `cmd; status=$?`                 |
| pipe status    | `"${PIPESTATUS[@]}"` + `set -o pipefail` |

## Parameter Expansion
| Operation      | Syntax                           |
|----------------|----------------------------------|
| Remove prefix  | `${var#pattern}` / `${var##pattern}` |
| Remove suffix  | `${var%pattern}` / `${var%%pattern}` |
| Default value  | `${var:-default}` / `${var:=default}` |
| Length         | `${#var}`                        |
| Substring      | `${var:offset:length}`           |

## Argument Parsing
- Use `getopts` (builtin) for short options; a `while`/`case` loop over `"$@"` for long options
- Never parse with ad-hoc positional `$1 $2 $3` beyond trivial scripts

```bash
usage() { printf 'usage: %s [-v] [-o file] arg...\n' "${0##*/}" >&2; exit 2; }

verbose=0 outfile=""
while getopts ':vo:' opt; do
    case $opt in
        v) verbose=1 ;;
        o) outfile=$OPTARG ;;
        *) usage ;;
    esac
done
shift $(( OPTIND - 1 ))
```

## Error Handling
- Use exit status directly: `if cmd; then ...`
- Quick bail: `cmd || die "message"`
- **Wrong:** `cmd1 && cmd2 || die` — fires if `cmd2` fails even when `cmd1` succeeded
- **Correct:** `if cmd1 && cmd2; then ...; else die; fi`

## Cleanup and Resource Management
- Always use `trap cleanup EXIT` for temp files, lock files, background processes, etc.
- In Bash, `EXIT` fires on: normal exit, `set -e` bail, and untrapped fatal signals (SIGINT, SIGTERM, SIGHUP) — one trap covers all
- **Cannot catch:** `SIGKILL` (`kill -9`) and power loss — these are uncatchable by design

### Recommended Pattern
```bash
# Register trap BEFORE creating resources — if the script dies between
# mktemp and trap registration, the file leaks
cleanup() {
    rm -rf "${tmpdir:-}"                                    # -rf: silent if never created
    [[ -n ${bg_pid:-} ]] && kill "$bg_pid" 2>/dev/null
    return 0  
                                                # don't let cleanup change exit status
}
trap cleanup EXIT

tmpdir=$(mktemp -d)         # prefer temp directories over individual files
```

### Key Details
- Prefer `mktemp -d` (temp directory) over `mktemp` (temp file) — one `rm -rf` cleans up everything
- Use `rm -f` / `rm -rf` in cleanup — safe even if the resource was never created (because trap was registered first)
- For lock files, prefer `flock(1)` over manual lock files — atomic, handles stale locks, survives `SIGKILL`
- Temp file locations: `mktemp` uses `$TMPDIR` (most portable); `$XDG_RUNTIME_DIR` for per-user runtime data on Linux

## Dependency Checking
- Use `command -v` (builtin) — never `which` (external, inconsistent across distros)
- Check all deps upfront, report all missing at once — don't die on the first one

### Recommended Pattern
```bash
require() {
    local missing=() cmd
    for cmd in "$@"; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    if (( ${#missing[@]} )); then
        printf >&2 '%s: missing required commands: %s\n' "${0##*/}" "${missing[*]}"
        exit 1
    fi
}

require curl jq rsync
```
Note: `"${missing[*]}"` (single joined string) — with `"${missing[@]}"` printf would recycle the
format string and produce garbage like `jq: missing required command: rsync`.

### Quick One-Liner (when custom messaging isn't needed)
```bash
type curl jq >/dev/null || exit
```
Bash's `type` prints `scriptname: line N: type: cmd: not found` for each missing command automatically.

## Built-in Networking
- Bash intercepts `/dev/tcp/host/port` and `/dev/udp/host/port` internally — these are not filesystem paths
- Requires Bash compiled with `--enable-net-redirections` (default on current major distros; Debian disabled it in older releases)
- **Does not work in:** sh, zsh (has its own `ztcp`), fish — it's a Bash feature, so it works anywhere Bash runs, including WSL and containers
- Verify support: `cat < /dev/tcp/google.com/80` — "No such file or directory" means the feature is disabled

### Port Check (preferred form)
```bash
# : (no-op) avoids sending data to the service
# Always wrap with timeout — a DROPped port hangs ~2 min otherwise
if timeout 3 bash -c ': < /dev/tcp/host/443' 2>/dev/null; then
    echo "open"
else
    echo "closed"
fi
```

### Wait for Service (deploy scripts)
```bash
until timeout 3 bash -c ': < /dev/tcp/localhost/5432' 2>/dev/null; do
    echo "waiting for postgres..."
    sleep 2
done
```

### Key Details
- `timeout` requires the `bash -c` wrapper — the redirection would otherwise be performed (and block) in the parent shell before `timeout` ever runs
- Prefer `if/then/else` over `&& ... ||` — the latter runs the "else" branch if *either* prior command fails

## Remote Execution (SSH)
- `ssh host 'cmd'` runs the command via the remote user's **login shell from `/etc/passwd`** with `-c` — which may not be Bash at all
- No startup files are reliably sourced: `.bash_profile` never; `.bashrc` only if the distro's Bash was compiled with `SSH_SOURCE_BASHRC` (Debian/Ubuntu: yes; most others: no) — and even then, most distro `.bashrc` files exit early for non-interactive shells:
  ```bash
  # Default guard found in most .bashrc files
  case $- in
      *i*) ;;
        *) return;;
  esac
  ```
- **Rule of thumb: assume nothing from the remote environment.** Set required options explicitly: `ssh host 'shopt -s globstar && ls **/*.txt'`
- Always single-quote the remote command to prevent **local** shell expansion: `ssh host 'ls /path/*.txt'`
- SSH concatenates unquoted arguments with spaces into a single string — quoting gets treacherous fast
- For complex commands, prefer piping a script (`ssh host bash < script.sh`) or copying one over — not inline quoting gymnastics

## Minimal Environment Fallbacks
When working in containers or stripped-down Linux where common tools are missing:

| Task | Missing Tools | Built-in Fallback |
|------|--------------|-------------------|
| TCP port check | `nc`, `nmap`, `telnet` | `timeout 3 bash -c ': < /dev/tcp/host/port'` |
| IP address | `ip`, `ifconfig` | `hostname -I` |
| DNS lookup | `dig`, `host` | `getent ahostsv4 example.com` |
| List TCP connections | `netstat`, `ss`, `lsof` | `awk 'NR>1 {print $2,$3,$4}' /proc/net/tcp` (hex-encoded) |

- `getent` also supports `ahostsv6` (IPv6) and `ahosts` (all families)
- `/proc/net/tcp` output is hex-encoded — addresses and ports need conversion for human readability
- `/proc/net/udp`, `/proc/net/tcp6`, `/proc/net/udp6` also available
- These fallbacks are for debugging/triage only — advocate for proper tooling in production images

## Style and Readability
- In scripts, prefer explicit arguments over brace expansion — `cp file file.bak` not `cp file{,.bak}`
- Brace expansion is great interactively but hurts readability in maintained scripts
- Brace expansion happens **before** variable expansion — `{$a,$b}` does not work as expected; use arrays instead
- Optimize for the next person reading the code, not keystroke count

## Common Pitfalls
| Bug | Fix |
|-----|-----|
| `[ $var = val ]` | `[[ $var == val ]]` |
| `arr=( $(cmd) )` | `readarray -t arr < <(cmd)` |
| `$var=val` or `var = val` | `var=val` |
| `[ $var = *.txt ]` | `[[ $var == *.txt ]]` |
| `cmd \| while ...` (subshell) | `while ...; done < <(cmd)` |
| `"~/path"` | `"$HOME/path"` |
| `printf "$var"` (format string injection) | `printf '%s\n' "$var"` |
| `{$a,$b}` (brace + variable) | Brace expansion happens first; use arrays or explicit args |
| `(( x++ ))` under `set -e` when `x=0` | `(( x += 1 ))` or `x=$(( x + 1 ))` |
| `local out=$(cmd)` (masks exit status) | `local out; out=$(cmd)` |
| `for f in *.log` with no matches | `shopt -s nullglob` first |

## Prefer Builtins Over Subprocesses
- **String operations:** Use parameter expansion (`${var##*/}`, `${var%.*}`) over `basename`, `dirname`, `sed`, `awk`, `cut` when the operation is a simple prefix/suffix strip
- **Conditionals:** Use `[[ $var == pattern ]]` over `echo "$var" | grep -q pattern`
- **Arithmetic:** Use `(( ))` over `expr` or `bc` (for integer math)
- **Array operations:** Use `"${arr[@]}"` slicing/iteration over piping to external tools
- `dirname` alternative: `${var%/*}` (but note: doesn't handle edge cases like bare filenames or `/` — use `dirname` if you need correct behavior for arbitrary paths)
````

