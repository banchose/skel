BASH_EXPERT_CONTEXT:
Version: Bash 5+
Mode: Expert scripting with safety/portability focus
Default: Functions over scripts, shellcheck-clean output

CRITICAL_SAFETY:

- Quote ALL expansions: "${var}" not $var
- Use [[]] over [ ] for conditions
- Prefer (( )) for arithmetic
- Always: set -euo pipefail (unless explicit error handling needed)
- Shebang: #!/usr/bin/env bash

COMMAND_SUBSTITUTION:

- Modern: var=$(cmd) NOT `cmd`
- Quote: "$(cmd)" prevents word splitting/globbing
- Preserve newlines: var=$(cmd; printf x); var=${var%x}
- File read: var=$(<file) # Bash-only, faster than $(cat file)

FILE_READING:

- Template: while IFS= read -r line || [[-n $line]]; do ...; done
- Always: -r flag (prevents backslash interpretation)
- Field splitting: IFS=':' read -r f1 f2 rest
- Sources: < file | <<< "$var" | < <(cmd) # process substitution avoids subshell
- Never: for line in $(cat file) # breaks on whitespace

DATA_STRUCTURES:

- Modern: declare -A map # associative arrays (Bash 4+)
- Access: "${map[key]}" keys: "${!map[@]}"
- Indirection: declare -n ref=varname; echo "$ref" # name references (Bash 4.3+)
- Security: NEVER eval with untrusted input
- Validate names: ^[a-zA-Z\_][a-zA-Z_0-9]\*$ before indirection

OUTPUT_CAPTURE:

- stdout: out=$(cmd)
- stderr: err=$(cmd 2>&1 >/dev/null)
- both: out=$(cmd 2>&1)
- status: cmd; status=$?
- pipe status: PIPESTATUS array, set -o pipefail

COMMON_PITFALLS:

- Unquoted expansions: [ $var = val ] → [ "$var" = val ]
- Word splitting in arrays: arr=( $(cmd) ) → readarray -t arr < <(cmd)
- Assignment syntax: $var=val → var=val, var = val → var=val
- Globbing in [ ]: [ $var = *.txt ] → [[$var = *.txt]] or [ "$var" = "*.txt" ]
- Process substitution vs pipes: cmd | while... # subshell issues
- Tilde in quotes: "~/path" → "$HOME/path"
- Format string attacks: printf "$var" → printf '%s\n' "$var"

PARAMETER_EXPANSION:

- Remove prefix: ${var#pattern} ${var##pattern}
- Remove suffix: ${var%pattern} ${var%%pattern}
- Default values: ${var:-default} ${var:=default}
- Length: ${#var}
- Substrings: ${var:offset:length}

ERROR_HANDLING:

- Test commands: if cmd; then... # uses exit status
- Explicit status: cmd || die "message"
- Multiple commands: cmd1 && cmd2 || die # WRONG if cmd2 can fail
- Correct: if cmd1 && cmd2; then ...; else die; fi

SUBPROCESS_MANAGEMENT:

- Background: cmd & wait $! # capture PID, wait for completion
- Process groups: ( cmd1; cmd2 ) & # subshell grouping
- File descriptors: exec 3< file; read -u 3 var; exec 3<&- # explicit FD management

