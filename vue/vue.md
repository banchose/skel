# Build vue app locally

```sh
#!/usr/bin/env bash

set -euo pipefail

# cd in the vue project (~/hrigit/pisal)
docker run -it -v $(pwd):/app -w /app node:latest npm run build
# Open a shell in a Node container with your project mounted
docker run -it -v $(pwd):/app -w /app node:latest /bin/bash
sleep 5
cd /app
echo "install npm"
npm install
sleep 5
echo "npm audit fix"
npm audit fix
echo "npm update"
npm update
echo "npm run build"
npm run build
exit
```

```sh
#!/usr/bin/env bash

set -euo pipefail

# Run all commands in a single Docker execution
docker run -v $(pwd):/app -w /app node:latest /bin/bash -c "
echo 'Installing dependencies...'
npm install

echo 'Running npm audit fix...'
npm audit fix --force || true

echo 'Updating packages...'
npm update || true

echo 'Building the project...'
npm run build
"

echo "Build completed!"
```
for reference, you need to add to project.json

```json
"overrides": {
  "vite": "^4.0.0"
}
```
```
version: '3'

services:
  builder:
    image: node:latest
    user: "1000:1000"
    volumes:
      - .:/app
    working_dir: /app
    tty: true
    command: bash -c "npm install --verbose --include=optional @vite@4 && npm audit fix --force || true && npm update || true && npm run build"
```
