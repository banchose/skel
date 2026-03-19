# fzf Reference — Patterns, Idioms & Useful Recipes

**Date:** 2026-03-14  
**Type:** Reference  
**Environment / Scope:** Linux, Bash/Zsh, fzf 0.48+

* * *

## Summary

Condensed reference for fzf usage patterns — core options, recurring idioms, git integration, and clever techniques extracted from practical examples. Optimized for quick lookup, not tutorial.

## Core Options & Flags

| Flag | Purpose |
| --- | --- |
| `--multi` | Allow multi-select (TAB to mark) |
| `--reverse` | Top-down layout |
| `--no-sort` | Preserve input order (important for logs, git) |
| `--ansi` | Parse ANSI color codes in input |
| `--preview='cmd {}'` | Live preview pane; `{}` = selected line |
| `--preview-window=POSITION` | `down`, `top:47%`, `right:50%`, etc. |
| `--header='text'` | Static header text |
| `--header-first` | Display header above the list |
| `--header-lines=N` | Treat first N input lines as sticky header |
| `--prompt='X > '` | Custom prompt string |
| `--preview-label='[ X ]'` | Label on preview border |
| `--accept-nth=N` | Only output the Nth column of selection |
| `--query="$1"` | Pre-fill the search query |

## Field & Placeholder Syntax

*   `{}` — full selected line
    
*   `{1}`, `{2}`, ... — whitespace-delimited fields (1-indexed)
    
*   `{+}` — all multi-selected lines (space-separated)
    
*   `{q}` — current query string
    

## Bind Actions — Key Idioms

```
--bind='key:action(args)+action2(args)'
```

| Action | What it does |
| --- | --- |
| `execute(cmd)` | Run cmd in subshell; fzf stays open |
| `execute(cmd)+abort` | Run cmd then close fzf |
| `reload(cmd)` | Replace entry list with output of cmd |
| `change-prompt(X > )` | Swap the prompt string |
| `change-preview(cmd)` | Swap the preview command |
| `change-preview-label([ X ])` | Swap the preview label |
| `change-header(text)` | Swap header text |
| `refresh-preview` | Force preview re-render |
| `preview-up` / `preview-down` | Scroll preview |
| `preview-half-page-up` / `preview-half-page-down` | Scroll preview by half page |
| `unbind(key)` / `rebind(key)` | Dynamically enable/disable bindings |
| `transform:shell-expr` | Conditionally emit action string (the toggle trick) |
| `start:action` | Run action on fzf startup |

## The Toggle/Mode-Switch Pattern

Use `transform` + `$FZF_PROMPT` to build a two-mode UI with a single keybinding:

```bash
--bind="ctrl-s:transform:[[ \$FZF_PROMPT =~ 'Add >' ]] \
  && echo 'change-prompt(Reset > )+reload($list_b)' \
  || echo 'change-prompt(Add > )+reload($list_a)'"
```

Same pattern works for ENTER — inspect prompt to decide which command to run and which list to reload. This is the core technique for building multi-mode fzf interfaces.

## Preview Swapping

Multiple preview modes via separate keybindings:

```bash
--bind='ctrl-f:change-preview-label([ Diff ])+change-preview(git diff --color=always {} | sed "1,4d")' \
--bind='ctrl-s:change-preview-label([ Status ])+change-preview(git status --short)' \
--bind='ctrl-b:change-preview-label([ Blame ])+change-preview(git blame --color-by-age {})'
```

Vim-style preview scrolling:

```bash
--bind='ctrl-y:preview-up' --bind='ctrl-e:preview-down' \
--bind='ctrl-u:preview-half-page-up' --bind='ctrl-d:preview-half-page-down'
```

## Merging Heterogeneous Sources with `column`

When piping multiple commands with different column counts into fzf, normalize with `column`:

```bash
cat <(echo 'UNIT/FILE LOAD/STATE ACTIVE/PRESET SUB DESCRIPTION') \
    <(systemctl list-units --legend=false) \
    <(systemctl list-unit-files --legend=false) \
| column --table --table-columns-limit=5 \
| fzf --header-lines=1 --accept-nth=1 \
      --preview="SYSTEMD_COLORS=1 systemctl status {1}"
```

Key pieces: process substitution `<(cmd)` to merge sources; `column --table` to align; `--accept-nth=1` to emit only the unit name; `--header-lines=1` to pin the synthetic header.

## History Push for Repeatability

After building a command string via fzf selection, push it into shell history so ↑+Enter repeats without re-fuzzing:

```bash
CMD="systemctl start $(fzf_select) && systemctl status \$_ || journalctl -xeu \$_"
eval $CMD
[ -n "$BASH_VERSION" ] && history -s "$CMD"
[ -n "$ZSH_VERSION" ] && print -s "$CMD"
```

`\$_` prevents expansion before eval; `$_` resolves to last argument of previous command at runtime.

## Common Recipes

### File finder with preview, open in editor

```bash
${EDITOR:-vim} $(fzf --preview="bat -f {}" --query="$1")
```

### Ripgrep → fzf → editor (open files matching a string)

```bash
mrg() {
    [[ -z "$1" ]] && { echo "Usage: mrg <pattern>"; return 1; }
    ${EDITOR:-vim} $(rg "$1" --files-with-matches \
      | fzf --preview="rg -p -A 4 -B 2 '$1' {}")
}
```

### Git log browser — select commit hash

```bash
git log --oneline --all --color=always \
| fzf -m --no-sort --ansi --preview='git show --color=always {1}' \
| awk '{print $1}'
```

### Git branch switcher (sorted by recent commit)

```bash
gb() {
    git checkout $(git branch -a --sort=-committerdate "$@" \
      | sed 's,remotes/origin/,,' | fzf | tr -d '[:space:]')
}
```

### Git branch listing with metadata + column alignment

```bash
git branch --all --color \
  --format=$'%(HEAD) %(color:yellow)%(refname:short)\t%(color:green)%(committerdate:short)\t%(color:blue)%(subject)' \
| column --table --separator $'\t' \
| fzf --ansi --reverse --no-sort
```

Use `$'\t'` as delimiter to avoid breakage from spaces in commit subjects.

## Git-Specific Patterns

### Reliable unstaged file list (works from subdirectories)

```bash
git ls-files --modified --deleted --other --exclude-standard --deduplicate \
  $(git rev-parse --show-toplevel)
```

### Staged file list with correct relative paths

```bash
git status --short | grep '^[A-Z]' | awk '{print $NF}'
```

### Extract commit hash from git log --graph lines

```bash
echo "$line" | grep -o "[a-f0-9]\{7\}" | sed -n "1p"
```

`sed -n "1p"` grabs only the first match — needed when commit subjects contain hashes.

Without `--graph`, life is simpler: `{1}` directly gives you the hash.

### Useful git diff flags

*   `--diff-algorithm=histogram` — reduces noise from common-element repetition
    
*   `--ignore-all-space` / `--ignore-blank-lines` — suppress whitespace-only diffs
    
*   `--color=always` — required when piping into fzf `--ansi`
    

### In-fzf git actions pattern

```bash
--bind='enter:execute(git add {+})+reload($unstaged_files)+refresh-preview'
--bind='alt-p:execute(git add --patch {+})+reload($unstaged_files)'
--bind='alt-e:execute(${EDITOR:-vim} {+})'
--bind='alt-c:execute(git commit)+abort'
--bind='alt-a:execute(git commit --amend)+abort'
```

## References

*   fzf ADVANCED.md: [https://github.com/junegunn/fzf/blob/master/ADVANCED.md](https://github.com/junegunn/fzf/blob/master/ADVANCED.md)
    
*   fzf-git.sh (junegunn's git bindings): [https://github.com/junegunn/fzf-git.sh](https://github.com/junegunn/fzf-git.sh)
    
*   fzf.fish (Fish shell plugin, good study material): [https://github.com/PatrickF1/fzf.fish](https://github.com/PatrickF1/fzf.fish)
    
*   Source article: [https://thevaluable.dev/fzf-git-integration](https://thevaluable.dev/fzf-git-integration)
    

* * *

## Additions

> Items added outside of a structured update. May be rough, incomplete, or shorthand.  
> These should be integrated into the note body on the next formal update.

_(none yet)_
