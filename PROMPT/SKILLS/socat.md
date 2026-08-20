---
name: socat
description: 'socat reference: address grammar, address types, option groups, TLS/UDP/PTY/EXEC options, canonical relay and tunnel one-liners, SOCAT_* env vars, and the pitfalls that break commands (fork on connectors, missing -T on UDP, raw vs rawer, su= vs su-d=, wait-slave). Use when writing, reading, or debugging socat commands, port forwards, TLS termination, serial/PTY bridges, or UDP/multicast relays.'
---

# socat

Compact reference. Assumes shell, TCP/UDP, TLS basics, and `nc`. This fills in
socat-specific syntax and the corners that get gotten wrong.

## Invocation grammar

```
socat [opts] <address1> <address2>
```

Each address: `TYPE:param1:param2,opt1,opt2=val`

- `:` separates required params; the first `,` ends params and begins options.
- `-` ≡ `STDIO`; `TCP` ≡ `TCP4`; bare `/path` ≡ `GOPEN:/path`; bare digit ≡ `FD:n`.
- Default: bidirectional, both sides read+write.
- `-u`: addr1→addr2 only. `-U`: addr2→addr1 only (so `-u A B` ≡ `-U B A`).
- Dual address `A!!B`: read from A, write to B (shell-escape: `\!\!`).
- **Option-group rule**: each option is legal only on certain address types
  (`creat` only on OPEN-group; `fork` only on listeners; `chroot`/`su-d` only on
  EXEC/SYSTEM). Mixing groups is the most common mistake.

## Top-level flags

- `-d -d` — fatal+error+warning+notice (sane default).
- `-lm<facility>` — stderr until accept loop, then syslog (daemon-friendly).
- `-T <sec>` — global inactivity timeout. Required for UDP relays.
- `--experimental` — gates `netns=`, some TUN features.

## Address types

- **Networking**: `TCP4`/`TCP4-LISTEN`, `UDP4`/`UDP4-LISTEN`/`UDP4-RECVFROM`/`UDP4-DATAGRAM`,
  `SSL`/`SSL-LISTEN` (alias `OPENSSL[-LISTEN]`), `SCTP*`, `DCCP*`,
  `UNIX-CONNECT`/`UNIX-LISTEN`, `VSOCK-CONNECT`/`VSOCK-LISTEN`, `IP4-DATAGRAM`,
  `SOCKET-DATAGRAM` (generic escape hatch).
- **Tunnels/proxies**: `PROXY:proxyhost:target:port` (HTTP CONNECT),
  `SOCKS4:host:target:port`, `TUN:addr/mask,up`, `INTERFACE:name` (raw iface).
- **Local I/O**: `STDIO`/`-`, `FILE:path`, `OPEN:path`, `GOPEN:path`, `PIPE`, `PTY`,
  `FD:n`, `READLINE`, `TEXT:"literal"`, `POSIXMQ-SEND:/q`/`POSIXMQ-RECV:/q`.
- **Subprocess**: `EXEC:'cmd'` (direct execvp), `SYSTEM:'shell cmd'` (via /bin/sh),
  `SHELL` (login shell as endpoint).

## Options (high-leverage / non-obvious)

- **Listener**: `fork`, `reuseaddr`, `max-children=N`, `range=<CIDR>`,
  `tcpwrap=<name>`, `pf=ip4|ip6`, `bind=<addr>`, `accept-timeout=<sec>`.
- **Connector**: `bind=<addr>` (source addr), `connect-timeout=<sec>`, `retry=N`,
  `readbytes=N`.
- **Subprocess hardening (EXEC/SYSTEM)**: `chroot=<dir>`, `su-d=<user>` (resolves uid
  *before* chroot — use this, not `su=`), `setgid=<grp>`, `pty`, `setsid`, `ctty`,
  `stderr`, `nofork` (replaces socat; wires peer fds directly to child),
  `fdin=N`/`fdout=N`.
- **File (OPEN-group)**: `creat`, `trunc`, `append`, `seek=N`, `seek-end=N`,
  `largefile`, `ignoreeof` (tail -f).
- **Terminal/serial**: `rawer` (prefer over `raw`), `crnl`/`crlf` (line-ending
  translation — needed for hand-rolled HTTP/SMTP/FTP), `escape=0xNN`, `cfmakeraw`.
- **PTY**: `link=<path>` (stable symlink), `wait-slave` (block until link opened —
  without it, immediate EOF).
- **READLINE**: `history=<file>`, `noecho=<regex>` (mask next line when peer output matches).
- **UDP/multicast/raw**: `so-broadcast`, `broadcast`,
  `ip-add-membership=group:iface`, `so-timestamp`, `ip-pktinfo` (Linux) /
  `ip-recvdstaddr,ip-recvif` (BSD), `ip-recverr`, `sp=<port>` (source port).
- **TLS**: `cert=<pem>` (cert+key), `cafile=<crt>` (trust anchor), `verify=0`
  (DISABLES verification — testing only), `cipher=`, `method=`.
- **Stream framing**: `shut-null` (sender emits zero-length write on EOF),
  `null-eof` (receiver treats zero-length as EOF). Pair them to bridge datagram
  semantics over TCP.
- **Unix sockets / MQ**: `unlink-early` (rm path before bind — avoids EADDRINUSE).
- **Generic socket**: `socktype=N`, `protocol=N`, `setsockopt-int=<level>:<opt>:<val>`.
- **Namespaces**: `netns=<name>` (Linux netns; needs `--experimental`).

## Canonical patterns

```bash
# Concurrent TCP forwarder (the workhorse)
socat TCP-LISTEN:1234,reuseaddr,fork TCP:host:80

# Hardened forwarder
socat -lmlocal2 TCP4-LISTEN:80,reuseaddr,fork,range=10.0.0.0/8,bind=lan0 \
                TCP4:backend:80,bind=wan0

# TLS termination (cleartext in, TLS out)
socat TCP-LISTEN:2305,fork,reuseaddr SSL:example.com:443

# mTLS server / client
socat OPENSSL-LISTEN:4443,reuseaddr,fork,cert=server.pem,cafile=client.crt -
socat - OPENSSL:host:4443,cafile=server.crt,cert=client.pem

# UDP relay (timeout mandatory)
socat -T 30 UDP-LISTEN:5000,fork TCP:backend:5000

# Multicast send+receive on a group
socat - UDP4-DATAGRAM:239.255.0.1:6666,bind=:6666,ip-add-membership=239.255.0.1:eth0

# Through an HTTP proxy
socat TCP-LISTEN:2022,reuseaddr,fork \
      PROXY:proxy.local:dest.example.org:22,proxyport=3128,proxyauth=user:pw

# Virtual serial over SSH
socat PTY,link=$HOME/dev/vmodem0,rawer,wait-slave \
      EXEC:'ssh modemhost socat - /dev/ttyS0,nonblock,rawer'

# Sandboxed EXEC handler
socat TCP4-LISTEN:5555,fork,reuseaddr,tcpwrap=svc \
      EXEC:/usr/local/bin/handler,chroot=/var/jail,su-d=nobody,pty,stderr

# Dual-address: input from terminal, replies to file
socat -d -d READLINE\!\!OPEN:out.txt,creat,trunc \
            SYSTEM:'read x; echo $x'

# Merge many inbound streams into one upstream
socat -U TCP:target:9999,end-close TCP-L:8888,reuseaddr,fork

# Bound-read on hostile peer
socat - TCP:host:31337,readbytes=1000

# tail -f a file to stdout
socat -u FILE:/var/log/x,seek-end=0,ignoreeof -
```

## SOCAT_* env vars (in EXEC/SYSTEM children)

`SOCAT_PEERADDR`, `SOCAT_PEERPORT`, `SOCAT_SOCKADDR`, `SOCAT_SOCKPORT`,
`SOCAT_IP_DSTADDR` (needs `ip-pktinfo`), `SOCAT_IP_IF`, `SOCAT_TIMESTAMP` (needs
`so-timestamp`). Used for logging, source-based dispatch, and recovering the
original destination after multicast or transparent-proxy redirect.

## Common pitfalls

- `fork` on a connecting address: illegal — fork belongs to listeners.
- `creat` on a TCP address: illegal — OPEN-group only.
- Forgetting `-T` on UDP relays: process never exits.
- `raw` where `rawer` is needed: residual termios processing leaks through.
- `su=` instead of `su-d=` with `chroot=`: passwd lookup happens after chroot, fails.
- Plain `close` semantics on a shared upstream with `fork`: use `end-close`.
- Missing `crnl`/`crlf` on hand-rolled HTTP/SMTP: protocol parse failures.
- `wait-slave` omitted on `PTY,link=`: socat sees instant EOF.
