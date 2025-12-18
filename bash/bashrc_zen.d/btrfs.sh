lsbtrfs() {
  for item in */; do
    if btrfs subvolume show "$item" &>/dev/null; then
      echo "[SUBVOL] $item"
    else
      echo "[DIR]    $item"
    fi
  done
}

#!/usr/bin/env bash

# Function to convert a directory to a BTRFS subvolume
# Usage: dir_to_btrfs_subvolume "/path/to/directory"
dir_to_btrfs_subvolume() {

  # Validate input
  if [[ $# -ne 1 ]]; then
    echo >&2 "Error: Function requires exactly one argument (directory path)"
    return 1
  fi

  local dir="${1}"

  # Ensure trailing slash is removed
  dir="${dir%/}"

  # Exit if not a directory
  if [[ ! -d "${dir}" ]]; then
    echo >&2 "Error: '${dir}' is not a directory"
    return 1
  fi

  # Check if already a subvolume
  if btrfs subvolume show "${dir}" &>/dev/null; then
    echo >&2 "Error: '${dir}' is already a BTRFS subvolume"
    return 1
  fi

  # Create temp directory with same parent
  local parent_dir="${dir%/*}"
  local dirname="${dir##*/}"
  local temp_dir="${parent_dir}/.${dirname}_temp_$(date +%s)"

  echo ""
  echo ""
  echo "Converting '${dir}' to a BTRFS subvolume..."
  echo ""
  echo ""
  echo "Attempting the move/rename directory..."
  echo ""
  echo ""
  if ! mv -i -v "${dir}" "${temp_dir}"; then
    echo "Error: Failed to move '${dir}' to temporary location" 1>&2
    return 1
  fi
  echo ""
  echo ""
  echo "Rename/move Successful"
  echo ""
  echo ""
  echo "Creating the subvolume..."
  echo ""
  echo ""

  # Move the original directory to temp location
  if ! mv "${dir}" "${temp_dir}"; then
    echo >&2 "Error: Failed to move '${dir}' to temporary location"
    return 1
  fi

  # Create the subvolume
  if ! sudo btrfs subvolume create "${dir}"; then
    echo >&2 "Error: Failed to create subvolume at '${dir}'"
    # Try to restore original directory
    mv "${temp_dir}" "${dir}"
    return 1
  fi

  echo ""
  echo ""
  echo "Subvolume create successful"
  echo ""
  echo ""
  echo "Copying to the newly created subvolume..."
  echo ""
  echo ""

  # Copy all contents including hidden files and preserving attributes
  if ! sudo cp -a "${temp_dir}/." "${dir}/"; then
    echo >&2 "Error: Failed to copy contents to the new subvolume"
    echo >&2 "Original contents preserved at '${temp_dir}'"
    return 1
  fi

  echo ""
  echo ""
  echo "Copying successful"
  echo ""
  echo ""
  echo "Changing permissions on copied directories and files"
  echo ""
  echo ""

  # Set correct ownership
  if ! sudo chown -R --reference="${temp_dir}" "${dir}"; then
    echo >&2 "Warning: Failed to set proper ownership on '${dir}'"
    # Continue execution, as this is not fatal
  fi

  echo "Successfully converted '${dir}' to a BTRFS subvolume"
  echo "Original contents are backed up at '${temp_dir}'"
  echo "You can remove the backup with: rm -rf '${temp_dir}'"

  return 0
}

# Example usage (commented out):
# dir_to_btrfs_subvolume "/home/username/directory_to_convert"
