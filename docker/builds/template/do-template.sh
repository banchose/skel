#!/usr/bin/env bash
set -euo pipefail

# Parse arguments
build_only=false
while [[ $# -gt 0 ]]; do
  case "${1}" in
  -b | --build)
    build_only=true
    shift
    ;;
  *)
    echo "Unknown option: ${1}" >&2
    echo "Usage: ${0} [-b|--build]" >&2
    exit 1
    ;;
  esac
done

# Build only if flag is set
if [[ "${build_only}" == true ]]; then
  docker build -t template .
else
  # Run by default (assumes image already exists)
  docker run -it -v "$HOME"/temp:/home/template/temp:ro -v ./:/template --hostname template --name template --rm template:latest
fi
