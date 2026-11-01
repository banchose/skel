# Subject: my pi environment

This directory is where I come to talk about my pi setup: the container, the
image build, the agent config, skills, extensions, MCP servers, themes, and
the "subject directory" workflow itself.

## How I use pi

- pi runs in a docker container (`pi-sandbox`). I mount one directory from a
  GitHub repo to `/workspace` and make it the "subject" of the session.
  This one is `~/gitdir/configs/pi-dirs/mypi` on the host.
- The image and agent config come from `~/gitdir/skel/pi/` on the host:
  Dockerfile, build-pi.sh, COPY-MCP-TO-PI-IMAGE.sh, settings.json,
  mcp-adapter.json, AGENTS/AGENTS.md, extensions/, and
  skills -> ../PROMPT/SKILLS/pi/.
- `/home/node/.pi/agent` is a persistent docker volume (`pi-agent-home`). A
  seed script fills it from skel.
- Files in `/workspace` are only here as examples. They're not the subject
  and they may be stale or incomplete. Two exceptions:
- `AGENTS/AGENTS-running-now.md` is a snapshot of the live global
  `~/.pi/agent/AGENTS.md` (which comes from `~/gitdir/skel/pi/AGENTS/AGENTS.md`).
  `AGENTS/AGENTS-GLOBAL.proposed.md` is the staged next version: running-now
  plus additions I haven't adopted yet. When asked, diff the two, or diff
  running-now against the live file to check the snapshot is still current.
  When I adopt the proposed version I copy it to skel, re-seed the volume,
  and copy it over running-now so the two match again.
- `scripts/pi-agent.sh` is a hardlink to the live file
  `~/gitdir/skel/bash/bashrc_zen.d/pi-agent.sh` on the host. Edits here are
  live; I re-source it in my shell to pick them up. The file checks its own
  link at shell start and tells me if git ever split the two copies.
- `~/piland/` on the host holds my pi research projects, one git repo per
  directory, no remote. The model commits; `pi-backup` in pi-agent.sh is the
  only off-disk copy (encrypted tarball in Dropbox).

## How to work here

- Mostly discussion: explain, advise, compare, review. Don't edit files
  unless I ask. Show proposed changes as snippets or diffs I can apply in
  skel on the host.
- **Scratch files go in `/workspace/tmp/`**, never `/tmp`. The container's
  `/tmp` is gone when the session ends; `/workspace` is the only mount that
  survives. Backups, drafts, downloaded files, test output: all under
  `/workspace/tmp/`. It's gitignored.
- You can't reach the host. There is no docker and no git in here. `~` in my
  host scripts means `/home/una`, not `/home/node`.
- **Check the live environment instead of guessing.** It's right here:
  `~/.pi/agent/` (settings, skills, extensions, npm packages), `pi --version`,
  `command -v <tool>`, `env | grep ^PI_`.
- For questions about pi itself, read the pi docs under
  `/usr/local/lib/node_modules/@earendil-works/pi-coding-agent/` first.
- Never print `~/.pi/agent/auth.json` or `~/.pi/agent/mcp-adapter.json`.
  They may hold tokens.
