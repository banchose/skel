#!/usr/bin/env bash

set -xeuo pipefail

FILE=/home/una/.local/share/pipx/venvs/llm/lib/python3.14/site-packages/llm/models.py

# Backup first
cp "$FILE" "${FILE}.bak"

# Make the change
python3 -c "
content = open('$FILE').read()
old = '''            db[\"tool_responses\"].insert(
                {
                    \"tool_id\": tool_id,
                    \"response_id\": response_id,
                }
            )'''
new = '''            db[\"tool_responses\"].insert(
                {
                    \"tool_id\": tool_id,
                    \"response_id\": response_id,
                },
                ignore=True,
            )'''
assert old in content, 'Pattern not found — aborting'
open('$FILE', 'w').write(content.replace(old, new, 1))
print('Done')
"
