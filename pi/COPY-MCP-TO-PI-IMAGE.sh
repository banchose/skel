docker run --rm \
  -v pi-agent-home:/home/node/.pi/agent \
  -v ~/gitdir/skel/pi/mcp.json:/tmp/mcp.json:ro \
  --entrypoint bash pi-sandbox \
  -c 'install -m 600 -o node -g node /tmp/mcp.json /home/node/.pi/agent/mcp.json'
