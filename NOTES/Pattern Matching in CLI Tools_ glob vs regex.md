# Pattern Matching in CLI Tools: glob vs regex

A summary of how `-I` / ignore / pattern flags differ across common CLI tools.

## The Core Confusion

The same flag letter (often `-I` or `-P`) and the same intuitive purpose ("match/ignore this") can use **completely different pattern languages** depending on the tool.

| Tool | Flag | Pattern Type | Notes |
| --- | --- | --- | --- |
| `tree` | `-I`, `-P` | **glob** (wildcard) | `*`, `?`, `[...]`, `|` for alternation |
| `ag` (Silver Searcher) | `-I`, `-G`, search pattern | **PCRE regex** | Full regex syntax |
| `find` | `-name`, `-path`, `-lname` | **glob** (fnmatch) | Shell-style wildcards |
| `find` | `-regex`, `-iregex` | **regex** | Emacs regex by default; changeable via `-regextype` |

## Why `.git` Works Everywhere (but Misleadingly)

In **glob**, `.` is a literal dot.  
In **regex**, `.` means "any character."

For the string `.git`, both interpretations match the same thing in practice — so the distinction is invisible until you use a more complex pattern.

## `find` Specifics

`find` is the most complex — it has **both** pattern types:

*   `-name`, `-iname`, `-path`, `-ipath` → glob (fnmatch)
    
*   `-regex`, `-iregex` → regex (default: Emacs syntax)
    

**Critical** `-regex` **gotcha:** it matches the **entire path**, not just the filename:

```bash
# Wrong - won't match
find . -regex '\.git'

# Correct - must anchor the full path
find . -regex '.*/\.git'
```

## Excluding `.git` — Recommended Approaches

**tree:**

```bash
tree -I '.git'
# Multiple patterns:
tree -I '.git|node_modules'
```

**ag** — handled automatically via `.gitignore`; or explicitly:

```bash
ag --ignore '.git' pattern
```

**find** — use glob + `-prune` (most idiomatic):

```bash
find . -name '.git' -prune -o -print
```

## Tip

When in doubt about which pattern type a tool uses, check the man page for words like:

*   **"wildcard"** or **"shell pattern"** or **"fnmatch"** → glob
    
*   **"regular expression"** or **"PCRE"** or **"regex"** → regex