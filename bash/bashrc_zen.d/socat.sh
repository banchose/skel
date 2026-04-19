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
## Write to file

```
socat -u TCP-LISTEN:8005 CREATE:"$HOME"/temp/boom
netcat localhost 8005
tail -f "$HOME"/temp/boom
```

## OPENSSL Chat
  
### Make cert/key

```
openssl req -x509 -newkey rsa:2048 -keyout server.key -out server.crt \
    -days 30 -nodes -subj "/CN=localhost"
cat server.key server.crt > server.pem
chmod 600 server.pem
```
### Start Server

```
socat OPENSSL-LISTEN:4443,reuseaddr,cert=server.pem,verify=0 -
```

### Start Client

```
socat - OPENSSL:localhost:4443,cafile=server.crt
```

### OPENSSL Chat: verify=1

#### Create a cert for the client

```
openssl req -x509 -newkey rsa:2048 -keyout client.key -out client.crt \
    -days 30 -nodes -subj "/CN=client"
cat client.key client.crt > client.pem
chmod 600 client.pem
```

#### Tell server about the client crt and start

```
socat OPENSSL-LISTEN:4443,reuseaddr,cert=./server.pem,cafile=./client.crt -
```

#### Client

```
socat - OPENSSL:localhost:4443,cafile=$HOME/temp/cert/server.crt,cert=$HOME/temp/cert/client.pem
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
