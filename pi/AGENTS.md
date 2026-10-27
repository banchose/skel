# Subject: the pi image and agent-config build

This directory (`~/gitdir/skel/pi` on the host) is the source of truth for
the `pi-sandbox` container and the `pi-agent-home` volume. The global
instructions in `~/.pi/agent/AGENTS.md` still apply here.

## Layout

- `Dockerfile`, `build-pi.sh`: build the image, then `build-pi.sh` runs
  `COPY-MCP-TO-PI-IMAGE.sh` itself. `FULL=1` adds `--no-cache --pull`
  (fresh base image, every layer rebuilt).
- `COPY-MCP-TO-PI-IMAGE.sh`: seeds the `pi-agent-home` volume from this dir
  (settings, keybindings, AGENTS/AGENTS.md, mcp-adapter.json, skills,
  extensions, pi packages via `pi install npm:...`). Skills and extensions in the volume are wiped
  and recopied, so this dir is authoritative for them.
- `settings.json`, `mcp-adapter.json`, `keybindings.json`, `AGENTS/AGENTS.md`:
  the files that get installed. `OTHER-SETTINGS/` holds old settings
  variants kept for reference, not installed.
- `skills -> ../PROMPT/SKILLS/pi/`: the skills that get installed.
- `pi-agent.sh`: the host shell function (`pi-bed`) that runs the container.
- `diff-jsons.sh`: compares installed settings/keybindings against this dir.
- `*-w.*` files are a separate variant. Ignore them unless asked.

## How to work here

- Anything changed at runtime in the volume (`/mcp-adapter enable`,
  `/settings`, `pi install`) is overwritten on the next
  `COPY-MCP-TO-PI-IMAGE.sh`. Changes that should stick go in this dir.
- The live state is right here to check: `~/.pi/agent/`, `pi --version`,
  `env | grep ^PI_`. Compare against this dir instead of guessing.
- Python in the image: use apt (`python3-*`) when Debian has the package.
  Anything else goes into the `/opt/pyvenv` venv (`--system-site-packages`,
  first on PATH). Never `pip install --break-system-packages`: it deletes
  Debian's files (it once removed `python3-pil` and `python3-pdfminer`,
  which ocrmypdf needs through `/usr/bin/python3`).
- Never print `mcp-adapter.json` or `~/.pi/agent/auth.json`; they hold
  tokens. Use `jq` to inspect structure or boolean fields only.
- You can't reach the host, and there is no docker. `git` is installed but
  `/workspace` is not a repo from in here (`.git` is above the mount), so
  git commands fail. `~` in host scripts is `/home/una`.
