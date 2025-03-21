# Troubleshooting

- The dashboard has to have a trailing `/`
- Not `https:`
- The dashboard can be hit remotely after install with no auth
- Apps need labels to "join" the traefik network and be registered
- using curl, make sure to set the `-H "Host: host.abc.org`

