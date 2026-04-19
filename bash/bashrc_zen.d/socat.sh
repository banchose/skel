# Bail early if the command isn't available (only meaningful when sourced)
(return 0 2>/dev/null) || {
  printf >&2 '%s: must be sourced, not executed\n' "${BASH_SOURCE[0]}"
  exit 1
}

command -v socat >/dev/null 2>&1 || return 0

alias socat='socat -d -d'

socat_help() {
  cat <<'EOF'
# Socat

## Connect terminal to endpoint

```sh
socat STDIO TCP4:localhost:1234
```

## single-shot

```sh
socat TCP4-LISTEN:4321 TCP4:localhost:1234
```

## reuse

```sh
socat TCP-LISTEN:1234,reuseaddr,fork TCP:localhost:80
```

## write stdin to a file

```sh
socat -u FILE:test.txt,create STDIO
```

## cap at 1000 bytes

```sh
socat - TCP:www.blackhat.org:31337,readbytes=1000
```
## tls

```sh
socat TCP-LISTEN:2305,fork,reuseaddr ssl:example.com:443
```
## options

-u address1 r/o, address2 w/o
-U revese ?
-d -d print fatal+error+warning+notice messages
-d -d -d info too
EOF
}

editsocat() {
  nvim ~/gitdir/skel/bash/bashrc_zen.d/socat.sh
}
