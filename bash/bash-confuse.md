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

---

## Subshell vs. New Shell Instance

**Subshell = fork.** A near-exact copy of the parent shell process.

### Subshell (`( ... )`)

- Inherits **everything**: all variables (exported *and* non-exported), functions, file descriptors, working directory, etc.
- Does **not** increment `SHLVL`
- `$$` still reports the **parent's** PID; use `$BASHPID` for the subshell's actual PID
- Modifications (variables, `cd`, etc.) **do not propagate back** to the parent — it's a copy, not shared state
- Bash creates subshells implicitly in: pipelines, command substitution `$(...)`, process substitution `<(...)`, and explicit `( ... )` grouping

### New bash instance (`bash`, running a script)

- **Reinitializes** — only sees exported environment variables
- Regular (non-exported) variables, functions (unless `export -f`), etc. are gone
- **Increments `SHLVL`**

### Summary

**subshell = fork (copy everything), new bash = reinitialize (environment only)**
