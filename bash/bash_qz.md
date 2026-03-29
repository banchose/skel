# Bash quize

## 1

### Question

```bash
set -euo pipefail

count=0
echo -e "alpha\nbeta\ngamma" | while IFS= read -r line; do
    (( count++ ))
done
echo "Count: $count"
```

### Answer:

Prints 0

### What to learn

The `line` variable is assigned in a subshell created by the `|`

#### Eliminate the `|` pipe with `<`

```sh
while IFS= read -r line; do
    (( count++ ))
done < <(echo -e "alpha\nbeta\ngamma")
```
```
```
