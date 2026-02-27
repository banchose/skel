# Bash Confusions & Things to Understand

## Grammar Hierarchy: command → pipeline → list

The Bash grammar builds up in layers, where each level is "one or more of the previous level, separated by some operator":

*   **Simple command**: variable assignments + words + redirections (e.g., `x=1 ls`)
    
*   **Command**: a simple command, or a compound command (`if`, `while`, `{ ...; }`, `(...)`, etc.)
    
*   **Pipeline**: one or more commands separated by `|`
    
*   **List**: one or more pipelines separated by `;`, `&`, `&&`, `||`
    

A single command like `echo hello` is a pipeline of length one, which is a list of length one. Every construct nests cleanly without special cases.

### Variable assignments in simple commands

`x=1 ls` is a single simple command — `x=1` is a prefix assignment that applies to the environment of that command only. If there's no command word (just `x=1` by itself), the assignment persists in the current shell.

* * *

## Subshell vs. New Shell Instance

**Subshell = fork.** A near-exact copy of the parent shell process.

### Subshell (`( ... )`)

*   Inherits **everything**: all variables (exported _and_ non-exported), functions, file descriptors, working directory, etc.
    
*   Does **not** increment `SHLVL`
    
*   `$$` still reports the **parent's** PID; use `$BASHPID` for the subshell's actual PID
    
*   Modifications (variables, `cd`, etc.) **do not propagate back** to the parent — it's a copy, not shared state
    
*   Bash creates subshells implicitly in: pipelines, command substitution `$(...)`, process substitution `<(...)`, and explicit `( ... )` grouping
    

### New bash instance (`bash`, running a script)

*   **Reinitializes** — only sees exported environment variables
    
*   Regular (non-exported) variables, functions (unless `export -f`), etc. are gone
    
*   **Increments** `SHLVL`
    

### Summary

**subshell = fork (copy everything), new bash = reinitialize (environment only)**

* * *

## Alias Name Collides with Function Definition — `syntax error near unexpected token '('`

**This one bites repeatedly.** If you define an alias and then later define a function with the **same name**, bash expands the alias _during parsing_ before it ever sees the function definition syntax.

### What happens

```bash
alias llm_or_srch='llm -m "some/model" -o online 1'

# Later in the same file or session:
llm_or_srch() {
  llm -m some/model -o online 1 'do stuff'
}
```

Bash expands the alias first, so it actually tries to parse:

```bash
llm -m "some/model" -o online 1() {
```

This produces: `syntax error near unexpected token '('` — which is baffling because the function definition _looks_ perfectly fine.

### Why it's confusing

*   The error points at the `(` in `()` on the function definition line
    
*   The function definition syntax is correct — the problem is invisible (alias expansion happened before you see it)
    
*   Aliases are expanded at parse time, not execution time, so even if the alias is "above" the function in the same file, it's already active when bash parses the function definition below it
    

### The rule

**Aliases are simple textual shortcuts that expand during parsing. They replace only the first word of a command.** If that first word happens to also be used as `name() { ... }`, the alias expansion destroys the function definition syntax.

### Fixes

1.  **Delete the alias** if the function replaces it (most common — you probably wrote the function _because_ the alias was too limited)
    
2.  **Rename one of them** so they don't collide
    
3.  `unalias name 2>/dev/null` before the function definition (defensive, but ugly)
    

### Prevention checklist

*   Before defining a function, check: `type funcname` — if it says "alias," you have a collision
    
*   Prefer functions over aliases for anything non-trivial; aliases are only useful as simple textual shortcuts

* * *

## Single Quotes Cannot Contain Single Quotes — and the Concatenation Escape Hatch

### The absolute rule

**There is no way to include a literal single quote inside a single-quoted string.** No escape sequences work inside single quotes — everything is literal, period. There is no `\'` inside `'...'`.

### The `'\''` idiom — it's not what it looks like

`'\''` is **not** an escaped single quote inside a single-quoted string. It's four tokens that Bash concatenates:

| Token | Meaning |
|-------|---------|
| `'`   | End the current single-quoted string |
| `\'`  | A backslash-escaped literal single quote (**outside** any quotes) |
| `'`   | Start a new single-quoted string |

So `'don'\''t'` → `don't`. Ugly, but valid and widely used.

### The `'...' "..." '...'` concatenation trick

This is the key pattern to internalize. Bash concatenates adjacent string segments with different quoting into a single word. You can break out of single quotes, switch to double quotes for the part that needs expansion, then go back to single quotes:

```bash
'literal stuff' "$(expansion here)" 'more literal stuff'
```

**This is especially useful with `jq`**, where the jq filter itself needs single quotes but you need to inject a shell variable:

```bash
# WRONG — $var won't expand inside single quotes
jq '.items[] | select(.name == $var)'

# RIGHT — break out, double-quote the variable, go back
jq '.items[] | select(.name == "'"${var}"'")' file.json
```

Breaking that last jq argument down:

| Segment | Quoting | Result |
|---------|---------|--------|
| `'.items[] \| select(.name == "'` | single-quoted | literal jq filter text |
| `"${var}"` | double-quoted | shell variable expansion |
| `'")'` | single-quoted | closing jq syntax |

### Real-world example — alias with command substitution

```bash
alias llm_start='litellm --port 4000 >~/temp/litellm-log-'"$(date '+%s')"' 2>&1 &'
```

Three segments: `'...'` then `"$(date '+%s')"` then `' 2>&1 &'`.

**Gotcha:** `$(date)` expands **at alias definition time**, not invocation time. Every invocation gets the same timestamp. To defer expansion, keep it all single-quoted:

```bash
alias llm_start='litellm --port 4000 >~/temp/litellm-log-$(date +%s) 2>&1 &'
```

**Second gotcha:** `~` inside single quotes is **literal** — it won't expand to `$HOME`. It only expands when unquoted at the start of a word. Use `"$HOME"` via the concatenation trick, or just use a function instead.

### Just use a function

Functions sidestep all of this. Tilde expansion works normally, `$(...)` expands at invocation time, and quoting is straightforward:

```bash
llm_start() {
    litellm \
        --config ~/gitdir/skel/llm/litellm/litellm.conf \
        --port 4000 \
        >~/temp/litellm-log-"$(date '+%s')" 2>&1 &
}
```

### Quick reference

| Need | Pattern |
|------|---------|
| Literal single quote in single-quoted string | Impossible |
| Literal single quote via concatenation | `'text'\''more text'` |
| Shell expansion inside otherwise-single-quoted string | `'literal '"${var}"' literal'` |
| jq filter with shell variable | `jq '.key == "'"${var}"'"'` |
| Alias with deferred expansion | Keep `$(...)` inside the single quotes |
| Avoid all this pain | Use a function instead of an alias |