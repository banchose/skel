#!/usr/bin/env bash

set -xeuo pipefail

# Creates the template
# llm --sf ~/skel/PROMPT/the_weatherman.md -m anthropic/claude-sonnet-4-0 --save wet

llm -u -t Weatherman --functions ~/gitdir/skel/llm/weather_tool.py "Analyze the weather forecast and patterns" --td
