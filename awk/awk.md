# awk

`pattern { actions }`

- pattern action
  - pattern missing = every line
  - action missing = print `{ print }`
- `pattern { action statements }`
- `function name(parameter list) { statementes }`

## patterns

- `BEGIN`
- `END`
- `BEGINFILE`
- `ENDFILE`
- /regex/
- relation expression
- pattern && pattern
- pattern || pattern
- pattern ? pattern : pattern
- (pattern)
- ! pattern
- pattern1, pattern2
