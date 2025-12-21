#!/usr/bin/env bash
set -euo pipefail # Removed -x temporarily for cleaner output

# Check if network exists, create only if it doesn't
if ! docker network inspect internal0 >/dev/null 2>&1; then
  echo "Creating network internal0..."
  docker network create internal0
else
  echo "Network internal0 already exists, skipping creation."
fi

# Check if image exists, build only if it doesn't
if ! docker image inspect netshoot:myshoot >/dev/null 2>&1; then
  echo "Building image netshoot:myshoot..."
  docker build -t netshoot:myshoot .
else
  echo "Image netshoot:myshoot already exists, skipping build."
fi

# Check if container name is already taken
if docker ps -a --format '{{.Names}}' | grep -q "^netsh0$"; then
  echo "Container 'netsh0' already exists."

  # Check if it's running
  if docker ps --format '{{.Names}}' | grep -q "^netsh0$"; then
    echo "Status: RUNNING"
  else
    echo "Status: STOPPED"
  fi

  read -p "Do you want to remove it and redeploy? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing existing container netsh0..."
    docker rm -f netsh0
  else
    echo "Aborting. Container not redeployed."
    exit 0
  fi
fi

# Run the container
echo "Running container netsh0..."
set -x # Re-enable command echo for the run command
docker run -it --rm --hostname netsh0 --name netsh0 --network internal0 netshoot:myshoot
