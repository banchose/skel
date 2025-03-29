Context: BashPitfalls summary. User provided text outlining common Bash scripting errors & solutions. Objective: Condense for future session priming. Format uses Num: P(Problem): [Code/Concept] R(Reason): [Keyword(s)] S(Solution): [Code/Concept] N(Note): [Nuance/Context].

1: P: for f in $(ls *.mp3) R: WordSplit,Globbing,ls_mangle S: glob (./*.mp3), find -exec/print0, globstar; quote "$f" N: Handle no match (nullglob/-e)
2: P: cp $file $target R: WordSplit,Globbing S: cp -- "$file" "$target" N: Always quote var expansions.
3: P: Cmd -filename R: Leading dash interpreted as option S: Use -- (cmd -- "$file"), use paths (./file)
4: P: [ $foo = "bar" ] R: Unquoted var expansion (empty/spaces), WordSplit, Globbing S: [ "$foo" = bar ], [[ $foo == bar ]] N: [[ no split/glob; needs quotes for literal RHS pattern; x"$foo" for ancient shells.
5: P: cd $(dirname "$f") R: Unquoted CmdSubst S: cd -P -- "$(dirname -- "$f")"
6: P: [ "$v1" = v2 && "$v2" = v1 ] R: &&/|| invalid inside [ ] S: Use multiple [ ] ([ .. ] && [ .. ]) or [[ .. && .. ]] N: Avoid -a/-o (obsolescent).
7: P: [[ $foo > 7 ]] R: String comparison (>) vs numeric S: Use (( foo > 7 )) or [ "$foo" -gt 7 ] N: $((...)) vulnerable to injection if $foo unsanitized. [[... -gt 7]] uncommon. > in [ ] is file redirection.
8: P: cmd | while read; do var++; done R: Subshell scope (var changes lost) S: ProcessSubst (< <(cmd)), lastpipe opt (Bash>=4.2), restructure (ref FAQ#24)
9: P: if [grep foo file] R: Syntax misunderstanding ([ is cmd) S: Use cmd directly: if grep -q foo file; then...
10: P: [bar="$foo"]; [[bar=$foo]] R: Missing spaces around cmd/args/ops S: [ bar = "$foo" ]; [[ bar = "$foo" ]]
11: P: if [ [ a=b ] && [ c=d ] ] R: Syntax misunderstanding ([ is cmd, not grouping) S: if [ a = b ] && [ c = d ]; then... or if [[ a = b && c = d ]]; then...
12: P: read $foo R: Reads into var *named* by $foo S: read foo or IFS= read -r foo
13: P: cat file | sed s/foo/bar/ > file R: Read/write same file in pipeline S: Use temp file (sed '..' file > tmp && mv tmp file), sed -i, perl -pi -e
14: P: echo $foo R: Unquoted expansion (WordSplit, Globbing), may interpret options (-n) S: printf "%s\n" "$foo" N: echo "$foo" still vulnerable to options.
15: P: $foo=bar R: Incorrect assignment syntax ($ prefix) S: foo=bar or foo="bar"
16: P: foo = bar R: Incorrect assignment syntax (spaces) S: foo=bar or foo="bar"
17: P: echo <<EOF R: echo doesn't read stdin S: cat <<EOF, multiline quotes ("..."), printf %s "\..."
18: P: su -c 'cmd' R: Syntax incorrect on some OS (needs user) S: su user -c 'cmd' (usu. su root -c 'cmd')
19: P: cd /foo; bar R: Doesn't check cd success S: cd /foo && bar, cd /foo || exit 1, use subshell (cd /foo || exit; bar), pushd/popd
20: P: [ bar == "$foo" ] R: == invalid in POSIX [ ] S: Use = in [ ] ([ bar = "$foo" ]), or use [[ == ]] ([[ bar == $foo ]]) N: [[ $foo == pattern ]] is pattern match unless RHS quoted.
21: P: for i {1..10}; do cmd &; done R: Semicolon after & invalid S: Remove semicolon: do cmd & done
22: P: cmd1 && cmd2 || cmd3 R: Not safe if cmd2 fails (both cmd2 & cmd3 run) S: Use proper if/then/else/fi N: C-style 0=false for ((..)) exit status.
23: P: echo "Hello World!" R: Interactive history expansion (!) S: echo 'Hello World!', echo "Hello World"!, set +H, histchars= N: Bash>=4.3 less strict but still problematic inside quotes.
24: P: for arg in $* / $@ R: Incorrect iteration over params (WordSplit) S: for arg in "$@" or simply for arg
25: P: function foo() R: Non-portable syntax S: foo() { ... }
26: P: echo "~" R: Tilde expansion needs unquoted prefix S: Use "$HOME/path" instead of "~" in quotes.
27: P: local var=$(cmd) R: Masks cmd exit status ($?), potential word splitting S: Use two steps: local var; var=$(cmd); rc=$?
28: P: export foo=~/bar R: Tilde expansion inconsistent in export/local S: foo=~/bar; export foo or export foo="$HOME/bar"
29: P: sed 's/$foo/bar/' R: Vars not expanded in single quotes S: Use double quotes: sed "s/$foo/bar/" N: Beware nested quotes/escapes.
30: P: tr [A-Z] [a-z] R: Globbing ([A-Z]), incorrect TR syntax, locale-dependent range S: LC_COLLATE=C tr A-Z a-z (ASCII), tr '[:upper:]' '[:lower:]' (locale-aware) N: Need quotes for class names.
31: P: ps ax | grep gedit R: Unreliable process name matching, includes grep itself S: Use pgrep gedit, ps -C gedit, pidof gedit, pkill N: grep '[g]edit' avoids self-match; use ProcessManagement for robustness.
32: P: printf "$foo" R: Format string vulnerability if $foo has %,\ S: printf '%s\n' "$foo"
33: P: for i in {1..$n} R: Brace expansion before var expansion S: Use C-style loop: for ((i=1; i<=n; i++))
34: P: if [[ $foo = $bar ]] R: Pattern matching if RHS unquoted S: Quote RHS for literal match: [[ $foo = "$bar" ]]
35: P: if [[ $foo =~ 'RE' ]] R: RHS quoting forces literal match, not regex S: Use var: re='RE'; [[ $foo =~ $re ]] N: Also applies to *.glob patterns.
36: P: [ -n $foo ] / [ -z $foo ] R: Unquoted var expansion breaks [ ] S: Quote var: [ -n "$foo" ], or use [[ -n $foo ]]
37: P: [[ -e "$broken_symlink" ]] R: -e follows symlinks, fails if target missing S: [[ -e "$link" || -L "$link" ]]
38: P: ed <<< "g/d\{0,3\}/s//e/g" R: ed BRE doesn't accept {0,N} S: Use {1,N} or other tools.
39: P: expr "$word" : ".\(.*\)" fails for word="match" R: "match" is expr keyword S: GNU expr: expr + "$word" : ...; Better: Use parameter expansion: "${word#?}", "${word:1}"
40: P: UTF-8 BOM R: BOM breaks Unix tools/scripts (#!) S: Avoid BOM in Unix UTF-8 files.
41: P: content=$(<file) R: CmdSubst removes trailing newlines S: Add/remove marker: v_x=$(cmd; printf x); v=${v_x%x}; Alt: read -rd '' (portability issues, PIPESTATUS).
42: P: for file in ./* ; do if [[ $file != *.* ]] R: Pattern *.* matches ./file.* S: Match against base: [[ ${file##*/} != *.* ]], or use glob directly *.*, or use --.
43: P: cmd 2>&1 >>logfile R: Redirection order wrong (stderr to tty, then stdout to file) S: cmd >>logfile 2>&1
44: P: cmd; (( ! $? )) || die R: No need for $? in simple checks S: if cmd; then ...; Check specific $? with case.
45: P: y=$(( array[$x] )) R: $x expanded *before* arithmetic parsing -> injection S: Use var directly if possible. Escape: (( arr[\$idx]... )), use let '...', validate input. Affects AA/indexed.
46: P: read num; echo $((num+1)) R: Code Injection via arithmetic context S: Validate num before use (regex, case).
47: P: IFS=, read -ra fields <<< "a,b," R: read strips trailing empty field due to IFS termination S: Append IFS char to input: read ... <<< "$input," then optionally strip from last var.
48: P: export CDPATH=.:~/myProject R: Breaks scripts expecting local cd, pollutes subshell cmd output S: Don't export CDPATH. Scripts guard w/ unset CDPATH or ./prefix.
49: P: OIFS="$IFS"; ...; IFS="$OIFS" R: Doesn't preserve unset IFS state S: Use prefix marker (oIFS=${IFS+_${IFS}} ... IFS=${oIFS#_}), local var in function, or subshell.
50: P: arr=( $(cmd) ) R: Unsafe CmdSubst (WordSplit, Globbing) S: Single line: read -ra arr < <(cmd); Multi-line: readarray -t arr < <(cmd) (Bash>=4) or IFS=$'\\n' read -rd '' -a arr < <(cmd && printf '\\0') (Bash3 compat).
51: P: seq | xargs -P echo "$var" R: Non-atomic writes if output > pipe buffer -> interleaved output S: Use GNU Parallel or ensure atomic writes.
52: P: find . -exec sh -c 'echo {}' \; R: Code injection via {} S: Pass as arg: find . -exec sh -c 'echo "$1"' x {} \;
53: P: sudo cmd > /file R: Redirection happens as user, not root S: sudo sh -c 'cmd > /file' or cmd | sudo tee /file >/dev/null
54: P: sudo ls /foo/* R: Globbing happens as user, not root S: sudo sh -c 'ls /foo/*'
55: P: cmd 2>&- R: Closing stderr breaks programs expecting it S: Redirect: cmd 2>/dev/null or log properly.
56: P: find | xargs cmd R: xargs splits on whitespace/quotes S: Use find ... -print0 | xargs -0 cmd, or find -exec cmd {} +
57: P: unset a[0] R: Unquoted index subject to globbing, unset may target function S: unset -v 'a[0]'
58: P: month=$(date +%m); day=$(date +%d) R: Race condition near midnight S: Call date once: eval "$(date +'...')" or printf -v vars '%(...)T'; eval "$vars" or use epoch seconds and format later.
59: P: i=$(( 10#$i )) R: Fails for negative numbers S: i=$(( ${i%%[!+-]*}10#${i#[-+]} ))
60: P: set -euo pipefail R: Complex/subtle failure modes. -e: ignores errors in tested conditions/CmdSubst. pipefail: breaks if upstream cmd exits early (SIGPIPE). -u: OK-ish, use shellcheck. S: Use explicit error checks (cmd || die), local pipefail.
61: P: [[ -v hash[$key] ]] R: $key expansion before subscript eval (Bash<5.2), vulnerable S: Bash>=4.3: [[ -v 'hash[$key]' ]]; Fallback: test string val: [[ ${hash[$key]} ]]
62: P: (( hash[$key]++ )) R: $key expansion issue, worse in math ctx (Bash>=5.2) S: Use tmp var: tmp=${h[k]}; ((tmp++)); h[k]=$tmp. Alt: let 'hash[$key]++', h[k]=$(( ${h[k]} + 1 )). Backslash (( h[\$k]++ )) unsafe >=5.2.
63: P: while .. done <<< "$(foo)" R: Reads entire output first, modifies stream (NULs, trailing NLs removed, adds one NL), uses temp file S: Use ProcessSubst: while .. done < <(foo) or pipe: foo | while .. done
64: P: cmd > "file$((i++))" R: Redirection may run in subshell (optimisation), i++ lost S: Assign filename first: f="file$((i++))"; cmd > "$f". Or use group: { cmd ;} > "file$((i++))"
