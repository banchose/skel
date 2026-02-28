#!/usr/bin/env bash

echo "Echoing \$SHOE: $SHOE"
echo "${1:-}"
echo "${2:-}"
echo "${3:-}"

echo "This is \$1: ${1:-}"
echo "shift"
shift
echo "This is \$1: ${1:-}"
echo "shift"
shift
echo "This is \$1: ${1:-}"
echo "shift"
shift
echo "This is \$1: ${1:-}"
echo ""
echo ""

myfun() {
  echo "\$FUNCNAME: ${FUNCNAME[1]}"
  echo "\$FUNCNEST: ${FUNCNAME}"
}

myfun
