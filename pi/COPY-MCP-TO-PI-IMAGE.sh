# You will be the 'node' user as per the image build
docker run --rm \
  -v pi-agent-home:/home/node/.pi/agent \
  -v ~/gitdir/skel/pi/mcp.json:/tmp/mcp.json:ro \
  -v ~/gitdir/skel/pi/AGENTS.md:/tmp/AGENTS.md:ro \
  -v ~/gitdir/skel/pi/settings.json:/tmp/settings.json:ro \
  -v ~/gitdir/skel/PROMPT/SKILLS/pi:/tmp/SKILLS:ro \
  -v ~/gitdir/skel/pi/extensions/:/tmp/extensions:ro \
  --entrypoint bash pi-sandbox \
  -c 'set -e
      install -m 600 -o node -g node /tmp/mcp.json /home/node/.pi/agent/mcp.json
      install -m 644 -o node -g node /tmp/AGENTS.md /home/node/.pi/agent/AGENTS.md
      install -m 644 -o node -g node /tmp/settings.json /home/node/.pi/agent/settings.json
      ls -la /home/node/.pi/agent/
      cat /home/node/.pi/agent/AGENTS.md
      cat /home/node/.pi/agent/mcp.json
      mkdir -p /home/node/.pi/agent/skills
      cp -rv /tmp/SKILLS/*/ /home/node/.pi/agent/skills
      mkdir -p /home/node/.pi/agent/extensions
      cp -rv /tmp/extensions/*/ /home/node/.pi/agent/extensions
      [[ -d /home/node/.pi/agent/extensions/tinfoil ]] && ( cd /home/node/.pi/agent/extensions/tinfoil && npm ci )
      pi install git:github.com/nagisanzenin/engram
      pi install npm:@dietrichgebert/ponytail
      pi install npm:pi-mcp-adapter
      pi install npm:@narumitw/pi-plan-mode
      pi install npm:@narumitw/pi-btw
      pi install npm:@narumitw/pi-stamp
      pi install npm:@ff-labs/pi-fff
      pi install npm:@juicesharp/rpiv-ask-user-question
      pi install npm:@juicesharp/rpiv-todo
      pi install npm:@firstpick/pi-themes-bundle
      pi update --extensions
      pi update --models'

#      pi install npm:awesome-pi-themes
# pi install npm:@gotgenes/pi-permission-system
# npm ci
