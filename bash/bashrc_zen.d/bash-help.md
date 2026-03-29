# Bash short

## associative arrays no order

## evals

```sh
set -euo pipefail

x=5

if [[ $x -gt 3 ]] && [[ $x -lt 10 ]]; then
    echo "A"
fi

if (( x > 3 )) && (( x < 10 )); then
    echo "B"
fi

if (( x > 3 && x < 10 )); then
    echo "C"
fi

if [[ $x -gt 3 && $x -lt 10 ]]; then
    echo "D"
fi
# A
# B
# C
# D
```

## bash read pipe pattern

```
# WRONG
set -euo pipefail

printf '%s\n' "one" "two" "three" | read -r first
echo "$first"
```

```
# RIGHT
read -r first < <(printf '%s\n' "one" "two" "three")
```
```
```

## `[[ $msg == "$var"* ]]`

- Inside [[ ]], the right side of == is assembled from its parts.

## The same file in redirects

NO: `< file.txt > file.txt`


## Network port check

```sh
timeout 1 bash -c ': < /dev/tcp/registry/5000'"
```

## rsync

- copy one dir to another
- run again to update - dir HAS to be there
- mind the trailing slashes... Content's to contents

```bash
rsync -rltL /home/una/gitdir/skel/ /run/media/una/PNY256/skel/
```

## pipe past confusion

- The pipe kills the variable

## Remove preceeding spaces

```bash
while IFS= read -r line;do echo "${line##*[[:space:]] }";done < ./boom.txt
```

## while IFS= read -r

- Replaced a pattern like: `themes=($(bat --list-themes))` and `for i in "${themes[@]};do..."`

```bash
bat_show_themes() {
  bat --list-themes | while IFS= read -r theme; do
    echo "${theme}"
    bat -r 10:15 --theme "${theme}" ~/gitdir/skel/nvim/nvim-help.md
  done
}
```

## OOE

- brace
  - tilde
  - parameter and variable
  - arithmetic
  - command
- word splitting
- pathname expansion
- quote removal

## Order of expansion

- The order of expansions is: brace expansion; tilde expansion, parameter and variable expansion, arithmetic expansion, and command substitution (done in a left-to-right fashion); word splitting; pathname expansion; and quote removal.
- if a **variable** equals '*', that variable will expand, then later, **word splitting**, then **file expansion**
- File expansion AFTER variable expansion `b='[w-z]*'`;echo `$b`; works gets files starting with w-z

## pure-bash-bible

- `~/gitdir/skel/bash/pure-bash-bible.md`
- nvim: `gf`

## globstar

- `shopt -s globstar`
- `(shopt -s globstar; ...)` - sub shell leaves setting alone

- `**`: match all files and zero or more directories and **subdirectories**
- `**/`: only directories and subdirectories match
 
## Paramter Expansion

- `${parameter:-word}` - Good to avoid -e issues with undefined var
- `${parameter:=word}`
- `${parameter:?word}`
- `${parameter:+word}`
- `${parameter:offset}`
- `${parameter:offset:length}`

- `${#parameter}` length

- `${parameter#word}` Remove shortest matching prefix (word expanded) **pattern**
- `${parameter##word}` Remove longest matching prefix (word expanded) **pattern**
- `${parameter%word}` Remove longest matching suffix (word expanded) **pattern**
- `${parameter%%word}` Remove longest matching suffix (word expanded) **pattern**
- `${parameter/pattern/string}`
- `${parameter//pattern/string}`
- `${parameter/#pattern/string}`
- `${parameter/%pattern/string}`

## Conditional Expressions

### File tests

- `-f`: if file exists and is a regular file
- `-r`: if file readable
- `-w`: if file writable
- `-x`: if file writable
- `-d`: if file exists and is a directory
- `-L`: if file exists and is a symbolic link
- `-t`: if file exists and is a terminal

### Parameter tests

- `-z`: True if length of string is zero
- `-n`: True if length of string is non-zero

### String tests

- Pattern match equal: `[[ string1 = string2 ]]`
- Pattern match not equal: `[[ string1 != string2 ]]`
- True if string1 sorts before string2 lex: `[[ string1 < string2 ]]`
- True if string1 sorts after string2 lex: `[[ string1 > string2 ]]`

## Operations?

- `[[]]` evaluated as arithmetic expressions
  - `-eq`
  - `-ne`
  - `-lt`
  - `-le`
  - `-gt`
  - `-ge`
  - `[[]]` evaluated as arithmetic expressions


## blank

- space or tab

## whitespace

- a character belonging to the **space** character class in the current locale

## word (token)

- Anything but metacharacters 

## Metacharacter

- A character, when unquoted **separates** words
- The set: `|  & ; ( ) < > space tab newline`

## Control characters

- a **token** that performs a **control function**
- The set: `|| & && ; ;; ;& ;;& ( ) | |& <newline>`

## Reserved words

`! case  coproc  do done elif else esac fi for function if in select then until while { } time [[ ]]
`
- First word of a command
- 3rd word of a `case` or `select` command
- 3rd word of a `for` command
- all unquoted

## Interactive

- non-option arguments? (except `-s`) and no `-c`
- stdin/stdout hooked to terminal
- Sets PS1
- `$-` includes an `i`

## Login

- `/etc/profile`  (blocked by --noprofile)
  `~/.bash_profile ~/.bash_login ~/.profile` (blockec by --noprofile)

## Interactive non-login

- read `~/.bashrc`  (block by `--norc`, --rcfile /.bashrc.another)

## Non interactively

- Looks for `BASH_ENV`
- if there, uses it as the file name to execute
  - Will NOT use PATH to find the file
- `[ -n "$BASH_ENV" ]; then . "$BASH_ENV";fi`

## Process substitution

Process substitution allows a **process's** input or output to be referred to using a **filename**.

  - `<(list)`
  - `>(list)`

## Word splitting

- The shell scans the results of parameter expansion, command substitution, and arithmetic expansion that did not occur within double quotes for word splitting.  Words that were not expanded are not split.
- The shell treats each character of IFS as a **delimiter**, and splits the results of the other  expansions  into  words  using  these characters as **field terminators**.

