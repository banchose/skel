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

This produces: `syntax error near unexpected token '('` — which is baffling because the function definition _looks_ perfectly fine [1].

### Why it's confusing

*   The error points at the `(` in `()` on the function definition line
    
*   The function definition syntax is correct — the problem is invisible (alias expansion happened before you see it)
    
*   Aliases are expanded at parse time, not execution time, so even if the alias is "above" the function in the same file, it's already active when bash parses the function definition below it [1]
    

### The rule

**Aliases are simple textual shortcuts that expand during parsing. They replace only the first word of a command.** If that first word happens to also be used as `name() { ... }`, the alias expansion destroys the function definition syntax [1] [2].

### Fixes

1.  **Delete the alias** if the function replaces it (most common — you probably wrote the function _because_ the alias was too limited)
    
2.  **Rename one of them** so they don't collide
    
3.  `unalias name 2>/dev/null` before the function definition (defensive, but ugly)
    

### Prevention checklist

*   Before defining a function, check: `type funcname` — if it says "alias," you have a collision
    
*   Prefer functions over aliases for anything non-trivial; aliases are only useful as simple textual shortcuts [1]
