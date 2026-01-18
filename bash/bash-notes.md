# bash notes

## glob

Patterns that can be used to match filenames or other strings. Implicitly anchored at both ends

- `*`: Matches any string, including the null string.
- `?`: Match any single character
- `[...]`: Matches any one of the enclosed characters

## Word splitting

- Word splitting is done before filename expansion
- `*` returns `a b.txt` and not `a` and `b.txt`

### `*` does not split

### Helper script

```bash
#!/bin/sh -
printf "%d args:" "$#"
[ "$#" -eq 0 ] || printf " <%s>" "$@"
echo
```

```bash
touch "a b.txt"
rm *
```

### 'for' splits

- `for` splits into `a` and `b.txt`

```bash
ls
#=> a b.txt
for file in `ls`; do rm "$file"; done
#=> rm: cannot remove `a': No such file or directory
#=> rm: cannot remove `b.txt': No such file or directory
for file in *; do rm "$file"; done
ls
#=> nothing - worked
```

## Arrays

```bash
declare -p myfiles
declare -a myfiles='([0]="/home/wooledg/.bashrc" [1]="billing codes.xlsx" [2]="hello.c")'
```

```bash
file=(*)
names=("Bob" "Peter" "$USER" "Big Bad John")
photos=(~/"My Photos"/*.jpg)
```

## Regex

- Use a variable to store regex to avoid escaping and quoting

### Example 1

```bash
re='^\*( >| *Applying |.*\.diff|.*\.patch)'
[[ $var =~ $re ]]
```

### Example 2

```bash
langRegex='(..)_(..)'
if [[ $LANG =~ $langRegex ]]
then
    echo "Your country code (ISO 3166-1-alpha-2) is ${BASH_REMATCH[2]}."
    echo "Your language code (ISO 639-1) is ${BASH_REMATCH[1]}."
else
    echo "Your locale was not recognised"
fi
```

## case

### case example 1

- Instead of multiple `$var` like: `if [[ $var == foo || $var == bar || $var == more ]]`

```bash
# Bourne
   case $var in
      foo|bar|more) ... ;;
   esac
```

### case example 2

```bash
case $LANG in
    en*) echo 'Hello!' ;;
    fr*) echo 'Salut!' ;;
    de*) echo 'Guten Tag!' ;;
    nl*) echo 'Hallo!' ;;
    it*) echo 'Ciao!' ;;
    es*) echo 'Hola!' ;;
    C|POSIX) echo 'hello world' ;;
    *)   echo 'I do not speak your language.' ;;
esac
```

### case Example 3

```bash
# A simple menu:
while true; do
    echo "Welcome to the Menu"
    echo "  1. Say hello"
    echo "  2. Say good-bye"

    read -p "-> " response
    case $response in
        1) echo 'Hello there!' ;;
        2) echo 'See you later!'; break ;;
        *) echo 'What was that?' ;;
    esac
done

# Alternative: use a variable to terminate the loop instead of an
# explicit break command.

quit=
while test -z "$quit"; do
    echo "...."
    read -p "-> " response
    case $response in
        ...
        2) echo 'See you later!'; quit=y ;;
        ...
    esac
done
```

## Brace Expansion

```bash
echo th{e,a}n
#=> then than

echo {/home/*,/root}/.*profile
#=> /home/axxo/.bash_profile /home/lhunath/.profile /root/.bash_profile /root/.profile

echo {1..9}
#=> 1 2 3 4 5 6 7 8 9

echo {0,1}{0..9}
#=> 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19
```

## Tests

```
Tests supported by [ (also known as test) and [[:

    -e FILE: True if file exists.

    -f FILE: True if file is a regular file.

    -d FILE: True if file is a directory.

    -h FILE: True if file is a symbolic link.

    -p PIPE: True if pipe exists.

    -r FILE: True if file is readable by you.

    -s FILE: True if file exists and is not empty.

    -t FD : True if FD is opened on a terminal.

    -w FILE: True if the file is writable by you.

    -x FILE: True if the file is executable by you.

    -O FILE: True if the file is effectively owned by you.

    -G FILE: True if the file is effectively owned by your group.

    FILE -nt FILE: True if the first file is newer than the second.

    FILE -ot FILE: True if the first file is older than the second.

    -z STRING: True if the string is empty (its length is zero).

    -n STRING: True if the string is not empty (its length is not zero).
    String operators:

        STRING = STRING: True if the first string is identical to the second.

        STRING != STRING: True if the first string is not identical to the second.

        STRING < STRING: True if the first string sorts before the second.

        STRING > STRING: True if the first string sorts after the second.

    ! EXPR: Inverts the result of the expression (logical NOT).
    Numeric operators:

        INT -eq INT: True if both integers are identical.

        INT -ne INT: True if the integers are not identical.

        INT -lt INT: True if the first integer is less than the second.

        INT -gt INT: True if the first integer is greater than the second.

        INT -le INT: True if the first integer is less than or equal to the second.

        INT -ge INT: True if the first integer is greater than or equal to the second.

Additional tests supported only by [[:

    STRING = (or ==) PATTERN: Not string comparison like with [ (or test), but pattern matching is performed. True if the string matches the glob pattern.

    STRING != PATTERN: Not string comparison like with [ (or test), but pattern matching is performed. True if the string does not match the glob pattern.

    STRING =~ REGEX: True if the string matches the regex pattern.

    ( EXPR ): Parentheses can be used to change the evaluation precedence.

    EXPR && EXPR: Much like the '-a' operator of test, but does not evaluate the second expression if the first already turns out to be false.

    EXPR || EXPR: Much like the '-o' operator of test, but does not evaluate the second expression if the first already turns out to be true.

Tests exclusive to [ (and test):

    EXPR -a EXPR: True if both expressions are true (logical AND).

    EXPR -o EXPR: True if either expression is true (logical OR).
```
