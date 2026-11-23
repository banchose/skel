# ripgrep
# Bail early if the command isn't available (only meaningful when sourced)
(return 0 2>/dev/null) || {
  printf >&2 '%s: must be sourced, not executed\n' "${BASH_SOURCE[0]}"
  exit 1
}
command -v rg >/dev/null 2>&1 || return 0

alias editrg='nvim ~/gitdir/skel/bash/bashrc_zen.d/ripgrep.sh'
alias rgg='rg -L --smart-case --hidden --line-number --no-ignore'
alias rggl='rg -L --files-with-matches --line-number --smart-case --hidden --no-ignore'
alias rggc='rg -L --count-matches --line-number --smart-case --hidden --no-ignore'

help_rg() {

  cat <<'EOF'
# Search current directory
rg 'pattern'

# Search a specific directory
rg 'pattern' src/

# Search specific files
rg 'pattern' src/main.rs src/lib.rs

# Search stdin
echo "hello world" | rg 'hello'

# Only search 2 levels deep
rg 'pattern' --max-depth 2

# Include hidden files and directories
rg -. 'pattern'

# Do not respect .gitignore (but still skip hidden/binary)
rg --no-ignore 'pattern'

# Disable ALL filtering, including hidden and binary files
rg -uuu 'pattern'

# Show which files would be searched without actually searching
rg --files

# Only search .ts files
rg 'interface' -g '*.ts'

# Exclude test files
rg 'TODO' -g '!*.test.*'

# Multiple globs
rg 'import' -g '*.ts' -g '!*.d.ts'

# Exclude a directory
rg 'console.log' -g '!dist/**'

# Show all built-in file types
rg --type-list

# Only Python files
rg 'def ' -t py

# Everything except Markdown files
rg 'TODO' -T md

# Define a custom type and use it
rg --type-add 'web:*.{html,css,js,ts}' -t web 'className'

# Replace matches in output
rg 'fn (\w+)' -r 'function $1'

# Swap date format YYYY-MM-DD → DD/MM/YYYY
rg '(\d{4})-(\d{2})-(\d{2})' -r '$3/$2/$1'

# Named capture groups
rg '(?P<last>\w+), (?P<first>\w+)' -r '$first $last'

# To write changes back to a file, keep every line with --passthru,
# then save with sponge (from moreutils):
rg --passthru 'old_name' -r 'new_name' src/main.rs | sponge src/main.rs

# Force Latin-1 (ISO-8859-1) encoding
rg -E latin1 'pattern' legacy.txt

# Force Shift-JIS (Japanese)
rg -E shift-jis 'パターン' file.txt

# Common encoding labels:
# utf-8, utf-16, latin1, ascii, gbk, euc-jp, euc-kr, ...

# Treat binary files as text
rg -a 'pattern'

# Explicitly search a binary file
rg -a 'pattern' binary-file.bin

# Search inside .gz log files
rg -z 'ERROR' /var/log/app.log.gz

# Search all compressed logs in a directory
rg -z 'WARN' /var/log/nginx/

# Combine with type filter
rg -z 'pattern' -g '*.gz'

# Always use smart-case (case-insensitive unless pattern has uppercase)
--smart-case

# Always search hidden files
--hidden

# Always show line numbers (rg already does this in terminals, but useful for pipes)
--line-number

# Set a custom colors
--colors=match:fg:yellow

# Ignore some directories globally
--glob=!.git/
--glob=!node_modules/
--glob=!.venv/

# Point to a config file explicitly
RIPGREP_CONFIG_PATH=~/.ripgreprc rg 'pattern'

# Or export it in your shell profile
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# PowerShell
$env:RIPGREP_CONFIG_PATH = "$HOME\.ripgreprc"


rg -uuu 'pattern' # disable all 'ignore' fiters
rg 'pattern' --max-depth 2
rg --type-list
rg -t py
rg 'def ' -t py
--smart-case
--hidden
--glob, -g
rg 'import' -g '*.ts' -g '!*.d.ts'
EOF
}
