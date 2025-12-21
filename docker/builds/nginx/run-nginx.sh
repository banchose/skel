#!/usr/bin/env bash

set -xeuo pipefail

IMAGE=nginx:latest
NAME="${IMAGE%:*}0"

#!/usr/bin/env bash
set -euo pipefail # Removed -x temporarily for cleaner output

# Check if network exists, create only if it doesn't
if ! docker network inspect "${NAME}" >/dev/null 2>&1; then
  echo "Creating network ${NAME} ..."
  docker network create "${NAME}"
else
  echo "Network ${NAME} already exists, skipping creation."
fi

# Check if image exists, build only if it doesn't
if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  echo "Building image ${IMAGE} ..."
  docker build -t "${IMAGE}" .
else
  echo "Image ${IMAGE} already exists, skipping build."
fi

# Check if container name is already taken
if docker ps -a --format '{{.Names}}' | grep -q "${NAME}"; then
  echo "Container \'${NAME}\' already exists."

  # Check if it's running
  if docker ps --format '{{.Names}}' | grep -q "${NAME}"; then
    echo "Status: RUNNING"
  else
    echo "Status: STOPPED"
  fi

  read -p "Do you want to remove it and redeploy? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing existing container ${NAME} ..."
    docker rm -f "${NAME}"
  else
    echo "Aborting. Container not redeployed."
    exit 0
  fi
fi

# Run the container
echo "Running container ${NAME} ..."
set -x # Re-enable command echo for the run command
docker run -it --rm --hostname "${NAME}" --name "${NAME}" --network "${NAME}" "${IMAGE}"
