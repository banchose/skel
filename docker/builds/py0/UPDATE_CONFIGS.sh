#!/usr/bin/env bash

set -euo pipefail

command cp -v -- ~/.bashrc ~/gitdir/skel/docker/builds/py0/bashrc
command cp -v -- ~/gitdir/skel/llm/litellm/litellm.conf ~/gitdir/skel/docker/builds/py0/LLM
command cp -v -- ~/gitdir/skel/llm/TEMPLATES/*.yaml ~/gitdir/skel/docker/builds/py0/LLM/templates
