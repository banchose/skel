docker run --rm \
  -v pi-agent-home:/home/node/.pi/agent \
  -v ~/gitdir/skel/pi/mcp.json:/tmp/mcp.json:ro \
  -v ~/gitdir/skel/pi/AGENTS.md:/tmp/AGENTS.md:ro \
  --entrypoint bash pi-sandbox \
  -c 'set -e
      install -m 600 -o node -g node /tmp/mcp.json /home/node/.pi/agent/mcp.json
      install -m 644 -o node -g node /tmp/AGENTS.md /home/node/.pi/agent/AGENTS.md
      ls -la /home/node/.pi/agent/
      cat /home/node/.pi/agent/AGENTS.md
      cat /home/node/.pi/agent/mcp.json
      pi install git:github.com/nagisanzenin/engram
      pi install npm:@dietrichgebert/ponytail
      pi install npm:pi-mcp-adapter
      pi install npm:@narumitw/pi-plan-mode
      pi install npm:@narumitw/pi-btw
      pi install npm:@narumitw/pi-stamp
      pi install npm:@ff-labs/pi-fff'
# pi install npm:@gotgenes/pi-permission-system
