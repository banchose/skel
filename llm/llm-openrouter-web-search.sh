#!/usr/bin/env bash

set -euo pipefail

llm -m openrouter/mistralai/mistral-small -o online 1 'key events on march 1st 2025'

# llm -m claude-3.7-sonnet -o thinking 1 'Write a convincing speech to congress about the need to protect the California Brown Pelican'
