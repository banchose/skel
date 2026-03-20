# Grep

## quick

```sh
echo "who am I amamam" | grep -o '\bam\b'
grep -P
grep '^.' # match any character at the start of the line 
grep '^\.' # match the first '.' of the line
```

## Grep

- `grep -i` # ignore case
- `grep -v`: reverse, show lines that don't match the pattern
- `grep -o`: print matched parts of matched lines
- `grep -P`: perl regex

## Regular expressions

### Basic

- `.`  any char (except newline)
- `^`
- `[]`
- `[[:space:]]`

### Extended

- In  basic regular expressions the meta-characters `?`, `+`, `{`, `|`, `(`, and `)` lose their special meaning; instead use 
- The (NO -E) backslashed versions `\?`, `\+`, `\{`, `\|`, `\(`, and `\)`.

## Word boundries

- `\<`, `\>`, `\b`, `\B`, `\w`, `\W`

## Repitition

| Operator | Meaning |
|----------|---------|
| `?` | The preceding item is optional and matched at most once. |
| `*` | The preceding item will be matched zero or more times. |
| `+` | The preceding item will be matched one or more times. |
| `{n}` | The preceding item is matched exactly n times. |
| `{n,}` | The preceding item is matched n or more times. |
| `{,m}` | The preceding item is matched at most m times. (GNU extension) |
| `{n,m}` | The preceding item is matched at least n times, but not more than m times. |

## Character class

### Common

| Class | C/POSIX locale definition |
|-------|--------------------------|
| `[:alnum:]` | `isalpha(c) \|\| isdigit(c)` → uppercase + lowercase + `0-9` |
| `[:alpha:]` | `isupper(c) \|\| islower(c)` (plus locale extras) |
| `[:digit:]` | `0 1 2 3 4 5 6 7 8 9` |
| `[:space:]` | space, `\f`, `\n`, `\r`, `\t`, `\v` |
| `[:blank:]` | space, `\t` |
| `[:punct:]` | printable, not space, not alphanumeric |
| `[:xdigit:]` | `0-9 a-f A-F` (explicitly enumerated) |

### List

- `[[:alnum:]]`
- `[[:digit:]]`
- `[[:punct:]]`
- `[[:alpha:]]`
- `[[:graph:]]`
- `[[:space:]]`
- `[[:blank:]]`
- `[[:lower:]]`
- `[[:upper:]]`
- `[[:cntrl:]]`
- `[[:print:]]`
- `[[:xdigit:]]`
