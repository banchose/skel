#!/usr/bin/env bash

set -xeuo pipefail

# Usage info
show_help() {
  cat <<EOF
Usage: ${0##*/} [-hv] [-f OUTFILE] [FILE]...
Do stuff with FILE and write the result to standard output. With no FILE
or when FILE is -, read standard input.

    -h          display this help and exit
    -f OUTFILE  write the result to OUTFILE instead of standard output.
    -v          verbose mode. Can be used multiple times for increased
                verbosity.
EOF
}

# Initialize our own variables:
output_file=""
verbose=0

OPTIND=1
# Resetting OPTIND is necessary if getopts was used previously in the script.
# It is a good idea to make OPTIND local if you process options in a function.

while getopts hvf: opt; do
  case $opt in
  h)
    show_help
    exit 0
    ;;
  v)
    verbose=$((verbose + 1))
    ;;
  f)
    output_file=$OPTARG
    ;;
  *)
    show_help >&2
    exit 1
    ;;
  esac
done
shift "$((OPTIND - 1))" # Discard the options and sentinel --

# Everything that's left in "$@" is a non-option.  In our case, a FILE to process.
printf 'verbose=<%d>\noutput_file=<%s>\nLeftovers:\n' "$verbose" "$output_file"
printf '<%s>\n' "$@"

# End of file
