#!/usr/bin/env bash

set -xeuo pipefail

docker run --rm -v pi-agent-home:/a:ro -v ~/gitdir/skel/pi:/s:ro --entrypoint bash pi-sandbox \
  -c 'for f in settings.json keybindings.json; do diff -q /s/$f /a/$f; done'
