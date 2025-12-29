up-k9s() {
  local latest_version current_version

  # Check if k9s exists
  if ! command -v k9s &>/dev/null; then
    echo "k9s not found. Install it first." >&2
    return 1
  fi

  # Get current version - pure bash, reads first line and extracts second field
  read -r _ current_version _ < <(k9s version -s 2>/dev/null)

  # Fallback if version detection fails
  if [[ -z "${current_version}" ]]; then
    current_version="v0.0.0"
    echo "Warning: Could not detect current version" >&2
  fi

  # Get latest version from GitHub
  latest_version=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest |
    grep '"tag_name"' |
    sed -E 's/.*"([^"]+)".*/\1/')

  if [[ -z "${latest_version}" ]]; then
    echo "Failed to fetch latest version" >&2
    return 1
  fi

  echo "Current version: ${current_version}"
  echo "Latest version:  ${latest_version}"

  # Compare versions
  if [[ "${current_version}" == "${latest_version}" ]]; then
    echo "Already on latest version. Nothing to do."
    return 0
  fi

  if [[ "${current_version}" > "${latest_version}" ]]; then
    echo "Current version is newer than released version. Skipping."
    return 0
  fi

  echo "Upgrading from ${current_version} to ${latest_version}..."

  if curl -sL "https://github.com/derailed/k9s/releases/download/${latest_version}/k9s_Linux_amd64.tar.gz" |
    tar xvz -C ~/.local/bin k9s; then
    echo "Successfully upgraded k9s to ${latest_version}"
    k9s version
  else
    echo "Failed to upgrade k9s" >&2
    return 1
  fi
}
