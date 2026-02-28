#!/usr/bin/env bash

echo "Echoing \$SHOE: $SHOE"
echo "${1:-}"
echo "${2:-}"
echo "${3:-}"

echo "This is \$1: ${1:-}"
shift
echo "This is \$1: ${1:-}"
shift
echo "This is \$1: ${1:-}"
shift
echo "This is \$1: ${1:-}"
