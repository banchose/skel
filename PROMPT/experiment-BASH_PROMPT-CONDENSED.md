**Bash CmdSubst: Insert cmd output -> cmd/var. Syntax: $(cmd) (POSIX+, pref, easy nest) vs cmd (legacy, hard nest/\). Use: var=$(cmd), echo "$(cmd)". Quote "$()": prevents split/glob; nest=new quote ctx. Exec: Subshell (local var/CWD), $?=inner status. Output: strips trail \n; keep \n: $(cmd; printf x); ${var%x}. Bashism: $(<file) == $(cat file) (no fork). Ref: FAQ82 $() vs ``.**

Breakdown of the "language":

    Bash CmdSubst:: Topic.
    Insert cmd output -> cmd/var: Core function and target.
    **Syntax: $(cmd) (...) vs \cmd` (...)**: Compares the two forms with key characteristics (POSIX+, preferred, easy nesting for $(); legacy, hard nesting requiring ` for ``` ` ``).
    Use: var=$(cmd), echo "$(cmd)": Common usage patterns.
    Quote "$()": Focus on quoting the modern form.
    prevents split/glob: Effect of quoting.
    nest=new quote ctx: Quoting behavior in nested substitutions.
    Exec: Subshell (...): How it runs (subshell, implications: local vars/CWD).
    $? = inner status: How to get the exit status of the substituted command.
    Output: strips trail \n: Default output handling.
    keep \n: ...: The trick to preserve the trailing newline.
    Bashism: $(<file) == $(cat file) (no fork): Specific Bash optimization and its benefit.
    Ref: FAQ82 $() vs \``: Pointer to external resource comparing syntaxes.

Bash read File/Stream line/field: Use 'while IFS= read -r line || [[ -n $line ]]'. Options/Setup: '-r': ALWAYS (prevents \ interp). 'IFS=': no trim WS, reads whole line. 'IFS=<char>': split fields (e.g., IFS=:). Unset IFS: trim lead/trail WS (default). 'read f1 f2 last': 'last' gets rest; 'read _ skip _': use vars (not just _) to discard fields. '-d<delim>': change line delim (e.g., -d '' for NUL w/ find -print0). '-u FD' / '<&FD': read from FD # (avoid stdin stealing by inner cmds like cat/ssh). Handle no final \n: 'while ... || [[ -n $line ]]' OR check '$line' after loop. Input Src: '< file', '<<< "$var"' (Bash), '<<EOF\n$var\nEOF' (POSIX), 'cmd |' (SUBshell!), '< <(cmd)' (NO subshell). Process lines: loop body. Skip comments: '[[ $line = \#* ]]' (trimmed) or '[[ $line = *([[:blank:]])\#* ]]' (untrimmed, extglob?). Ref: FA(Q) 5(arr), 20(NUL), 24(subshell), 89(stdin steal). AVOID 'for' loop.

Breakdown of the "Language":

    Bash read File/Stream line/field:: Topic area.
    Use 'while IFS= read -r line || [[ -n $line ]]'.: Recommended core loop structure (handles missing final newline).
    Options/Setup:: Keyword for configuration variants.
    '-r': ALWAYS (prevents \ interp): Mandatory option and its function.
    'IFS=': no trim WS, reads whole line: Effect of empty IFS.
    'IFS=<char>': split fields (e.g., IFS=:): Setting IFS for splitting.
    Unset IFS: trim lead/trail WS (default): Default read behavior.
    'read f1 f2 last': 'last' gets rest: Field assignment overflow.
    'read _ skip _': use vars (not just _) discard fields: Field skipping technique (safer than just _).
    '-d<delim>': change line delim (...): Using -d (NUL example given).
    '-u FD' / '<&FD': read from FD # (...): Solution for input stealing using file descriptors.
    Handle no final \n: ... OR ...: Two main ways to deal with truncated last lines.
    Input Src: '< file', '<<< "$var"', '<<EOF...', 'cmd |' (SUBshell!), '< <(cmd)' (NO subshell): Different input methods and key characteristic (subshell warning for pipe).
    Process lines: loop body: Where the action happens.
    Skip comments: ...: Patterns for ignoring comment lines.
    Ref: FA(Q) ...: Pointers to related concepts/FAQs.
    AVOID 'for' loop.: Explicit negative instruction.


**`Bash AA/Indirect: Prefer AssocArrays (AA: Bash4+/ksh93) or Namerefs (NR: Bash4.3+/ksh93/zsh>5.9/mksh). AA: `declare -A map`; `map[key]=val`; access `${map[key]}`, keys `${!map[@]}`. Use AWK if no native AA. Nameref: `declare -n ref=varname`; use `$ref`/`${ref[@]}` like `varname`. Bash/mksh NR limitations (scope). AVOID indirection IF AA/NR/func suffice. Indirection Eval: Bash: `${!ref}` (old, issues); Zsh: `${(P)ref}`; Others: `eval` (DANGER!). Indirection Assign: NR best. Bash: `printf -v "$ref" val`, `read -r -- "$ref" <<< val`. Bash/ksh/zsh: `declare`/`typeset -- "${ref}=val"`. Portable: `eval "${ref}=\$val"` (HIGH DANGER - sanitize `$ref` & RHS quoting critical). SECURITY: `eval`/`declare`/`typeset`/`printf -v` = CODE EXEC RISK if `$ref` is untrusted (e.g., `ref='x[$(cmd)]'`). MUST validate ref names: `^[a-zA-Z_][a-zA-Z_0-9]*$`. Don't put code in vars.`**

**Breakdown:**

*   **`Bash AA/Indirect:`**: Topic: Associative Arrays & Indirection in Bash context.
*   **`Prefer AssocArrays (...) or Namerefs (...)`**: State preferred modern methods first, with shell support.
*   **`AA: ...`**: Syntax for Associative Arrays (declare, assign, access keys/values).
*   **`Use AWK if no native AA`**: Recommendation for older shells.
*   **`Nameref: ...`**: Syntax for Name References (declare, usage, limitations).
*   **`AVOID indirection IF AA/NR/func suffice`**: Strong recommendation against unnecessary complexity/risk.
*   **`Indirection Eval:`**: Section for evaluating *through* an indirect variable name.
    *   **`Bash: ${!ref} (old, issues)`**: Bash-specific legacy method.
    *   **`Zsh: ${(P)ref}`**: Zsh method.
    *   **`Others: eval (DANGER!)`**: The risky fallback.
*   **`Indirection Assign:`**: Section for assigning *to* an indirect variable name.
    *   **`NR best`**: Namerefs are safest for assignment.
    *   **`Bash: printf -v ..., read ...`**: Bash-specific safe-ish methods.
    *   **`Bash/ksh/zsh: declare/typeset ...`**: Methods with scope implications (and risk).
    *   **`Portable: eval "${ref}=\$val" (HIGH DANGER - ...)`**: The most portable but most dangerous method, highlighting critical quoting (`\$val`) and `$ref` sanitization need.
*   **`SECURITY: ... CODE EXEC RISK if $ref untrusted ...`**: Explicit security warning for *all* methods involving `$ref` evaluation/assignment (except dedicated Namerefs). Shows example attack vector.
*   **`MUST validate ref names: ...`**: Actionable advice: check variable names match expected pattern.
*   **`Don't put code in vars`**: General principle violated by naive indirection.

**`Bash Cap Cmd Output/Status: stdout->var: V=$(cmd). stdout+stderr->var: V=$(cmd 2>&1). Status->var: cmd; S=$?. Both: O=$(cmd); S=$?. Cond exec: 'if cmd' (just status); 'if O=$(cmd)' (status+stdout). stdout!=stderr (errors). Pipe: $?=last cmd status. Bash: PIPESTATUS[n]=nth status; 'set -o pipefail'=any fail breaks pipe. Cap ONLY stderr: discard stdout: E=$(cmd 2>&1 >/dev/null); stdout->tty: E=$(cmd 2>&1 >/dev/tty); swap stdout/stderr: E=$(cmd 3>&2 2>&1 1>&3-). Cap stderr, stdout pass-thru: exec 3>&1; E=$(cmd 2>&1 1>&3); exec 3>&- OR { E=$(cmd 2>&1 1>&3-) ;} 3>&1. CANNOT cap stdout/stderr -> sep vars w/o tmp file/pipe. Separator hack=non-robust.`**

**Explanation of the "Language":**

*   **`Bash Cap Cmd Output/Status:`**: Topic: Bash, Capture Command Output/Status.
*   **`stdout->var: V=$(cmd)`**: Assign stdout to variable V.
*   **`stdout+stderr->var: V=$(cmd 2>&1)`**: Assign combined stdout and stderr to V.
*   **`Status->var: cmd; S=$?`**: Run command, assign its exit status to S.
*   **`Both: O=$(cmd); S=$?`**: Capture output to O, then status to S.
*   **`Cond exec:`**: Conditional execution based on status.
*   **`'if cmd' (just status)`**: `if` checks command success (status).
*   **`'if O=$(cmd)' (status+stdout)`**: `if` checks status *and* captures stdout to O.
*   **`stdout!=stderr (errors)`**: Reminder that stdout is for data, stderr for errors (usually).
*   **`Pipe: $?=last cmd status`**: In a pipeline, `$?` holds the exit status of the *last* command.
*   **`Bash: PIPESTATUS[n]=nth status`**: Bash-specific array for statuses of *all* pipeline commands.
*   **`'set -o pipefail'=any fail breaks pipe`**: Bash option where *any* command failure causes the *entire* pipeline's status to be non-zero.
*   **`Cap ONLY stderr:`**: Recipes for capturing just stderr.
*   **`discard stdout: E=$(cmd 2>&1 >/dev/null)`**: Capture stderr to E, throw away stdout.
*   **`stdout->tty: E=$(cmd 2>&1 >/dev/tty)`**: Capture stderr to E, let stdout go to the terminal.
*   **`swap stdout/stderr: E=$(cmd 3>&2 2>&1 1>&3-)`**: Capture stderr to E, send original stdout to the script's original stderr (complex redirection).
*   **`Cap stderr, stdout pass-thru:`**: Recipes for capturing stderr while letting original stdout flow through unaffected. Uses temporary file descriptor (FD 3).
*   **`exec 3>&1; E=$(cmd 2>&1 1>&3); exec 3>&-`**: Method 1 using `exec`.
*   **`OR { E=$(cmd 2>&1 1>&3-) ;} 3>&1`**: Method 2 using grouped command and redirection scope.
*   **`CANNOT cap stdout/stderr -> sep vars w/o tmp file/pipe`**: Limitation: Can't put stdout and stderr into *different* variables using *only* standard redirections.
*   **`Separator hack=non-robust`**: Mentioning the non-recommended workaround using a unique string separator.


