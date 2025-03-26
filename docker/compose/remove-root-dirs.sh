#!/bin/bash
export UID=$(id -u)
export GID=$(id -g)

# Create directories with proper ownership
mkdir -p {images,logs,uploads,data-node,meili_data_v1.12}
chown -R $UID:$GID {images,logs,uploads,data-node,meili_data_v1.12}

# Start Docker Compose
sudo rm -rf ./data-node/ uploads/ logs/ images/
