# tinfoil — Pi skill

Source of truth for the Tinfoil knowledge base. Deploy by copying this directory to
`~/gitdir/skel/PROMPT/SKILLS/pi/tinfoil/` on the host; `COPY-MCP-TO-PI-IMAGE.sh`
then installs it into the `pi-agent-home` volume. For immediate use in a running
container: `cp -r /workspace/tinfoil ~/.pi/agent/skills/ && /reload`.

| Path | What |
| --- | --- |
| `SKILL.md` | what Pi loads: quick facts, chat-model table, gotchas, extension thinking maps |
| `scripts/models.sh` | verified `/v1/models` fetch via the extension's JS SDK |
| `scripts/sync-docs.sh` | re-download the cached docs pages |
| `references/*.md` | distilled notes: overview, api, models, verification, sdk-js, cli, pi-integration, troubleshooting, sources |
| `references/data/models.json` | raw catalog snapshot |
| `references/docs/` | verbatim markdown of 19 docs.tinfoil.sh pages (`.synced` = date) |

Snapshot date: 2026-10-23.
