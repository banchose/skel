#!/usr/bin/env bash

set -xeuo pipefail

docker run --rm -v pi-agent-home:/a:ro -v ~/gitdir/skel/pi:/s:ro --entrypoint bash pi-sandbox \
  -c 'diff <(jq -S "del(.lastChangelogVersion)" /s/settings.json) <(jq -S "del(.lastChangelogVersion)" /a/settings.json) && echo "settings.json: same (ignoring lastChangelogVersion)"
      diff -q /s/keybindings.json /a/keybindings.json && echo "keybindings.json: same"'
