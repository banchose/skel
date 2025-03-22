# sudo btrfs subvolume snapshot -r /home/una/subv /home/una/subv_snap

dir_to_btrfs_subvolume() {
  if [[ $# -ne 1 ]]; then
    echo "Error: Function requires exactly one argument (directory path)" 1>&2
    return 1
  fi
  local dir="${1}"
  dir="${dir%/}"
  if [[ ! -d "${dir}" ]]; then
    echo "Error: '${dir}' is not a directory" 1>&2
    return 1
  fi
  if btrfs subvolume show "${dir}" &>/dev/null; then
    echo "Error: '${dir}' is already a BTRFS subvolume" 1>&2
    return 1
  fi
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
  if ! sudo btrfs subvolume create "${dir}"; then
    echo "Error: Failed to create subvolume at '${dir}'" 1>&2
    mv -i -v "${temp_dir}" "${dir}"
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
  if ! sudo cp -a "${temp_dir}/." "${dir}/"; then
    echo "Error: Failed to copy contents to the new subvolume" 1>&2
    echo "Original contents preserved at '${temp_dir}'" 1>&2
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
  if ! sudo chown -R --reference="${temp_dir}" "${dir}"; then
    echo "Warning: Failed to set proper ownership on '${dir}'" 1>&2
  fi
  echo "Successfully converted '${dir}' to a BTRFS subvolume"
  echo "Original contents are backed up at '${temp_dir}'"
  echo "You can remove the backup with: rm -rf '${temp_dir}'"
  return 0
}
