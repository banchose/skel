#!/bin/bash

# Check if source directory is provided as argument
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <source_directory> [target_directory]"
  echo "If target_directory is not specified, './compose_dirs' will be used"
  exit 1
fi

source_dir="$1"
target_dir="${2:-./compose_dirs}"

# Check if source directory exists
if [[ ! -d "$source_dir" ]]; then
  echo "Error: Source directory '$source_dir' not found!"
  exit 1
fi

# Create target directory if it doesn't exist
mkdir -p "$target_dir"

echo "Copying Docker Compose files from '$source_dir' to '$target_dir'..."

# Use process substitution to avoid subshell issues with variables
while IFS= read -r dir || [[ -n "$dir" ]]; do
  # Use command substitution with proper quoting
  dirname="$(basename "$dir")"

  # Check if docker-compose files exist using [[ ]] for better Bash conditionals
  if [[ -f "$dir/docker-compose.yaml" || -f "$dir/docker-compose.yml" ]]; then
    # Create corresponding directory in target
    mkdir -p "$target_dir/$dirname/"
    echo "Processing: $dirname"

    # Use Bash's optimized file reading where appropriate
    for compose_file in docker-compose.{yaml,yml} docker-compose.override.{yaml,yml}; do
      if [[ -f "$dir/$compose_file" ]]; then
        # Preserve file attributes with cp -p
        cp -p "$dir/$compose_file" "$target_dir/$dirname/"
        echo "  - Copied $compose_file"
      fi
    done
  else
    echo "Skipping: $dirname (no docker-compose.yaml/yml found)"
  fi
  # Use process substitution to avoid a subshell and preserve variable scope
done < <(find "$source_dir" -mindepth 1 -maxdepth 1 -type d)

echo "Operation completed. Directories with Docker Compose files copied to '$target_dir'"
