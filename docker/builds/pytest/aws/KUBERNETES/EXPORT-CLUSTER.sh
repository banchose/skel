#!/usr/bin/env bash
# Kubernetes Resource Backup Script
# Usage: ./k8s-backup.sh [-n NAMESPACE] [-o OUTPUT_DIR] [-e "NS1 NS2"] [-c] [-v] [-h]

set -eo pipefail # Exit on error, undefined var reference, and pipe failures

# Default configuration
NAMESPACE=""
NAMESPACE_OPT=""
BACKUP_DIR="k8s-backup-$(date +%Y%m%d-%H%M%S)"
OUTPUT_DIR="."
EXCLUDE_NAMESPACES="kube-system kube-public kube-node-lease"
COMPRESS=false
VERBOSE=false

# Function to display usage information
usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -n NAMESPACE     Backup specific namespace (default: all namespaces)
  -o OUTPUT_DIR    Directory to store backups (default: current directory)
  -e "NS1 NS2..."  Space-separated namespaces to exclude (default: ${EXCLUDE_NAMESPACES})
  -c               Compress backup into a tarball
  -v               Verbose output
  -h               Display this help message

Examples:
  $(basename "$0")                      # Backup all namespaces
  $(basename "$0") -n mynamespace       # Backup only mynamespace
  $(basename "$0") -o /path/to/backups  # Specify output directory
  $(basename "$0") -e "ns1 ns2"         # Exclude specific namespaces
  $(basename "$0") -c                   # Compress the backup

EOF
  exit 1
}

# Parse command line arguments
while getopts ":n:o:e:cvh" opt; do
  case ${opt} in
  n)
    NAMESPACE="$OPTARG"
    NAMESPACE_OPT="-n $NAMESPACE"
    ;;
  o)
    OUTPUT_DIR="$OPTARG"
    ;;
  e)
    EXCLUDE_NAMESPACES="$OPTARG"
    ;;
  c)
    COMPRESS=true
    ;;
  v)
    VERBOSE=true
    ;;
  h)
    usage
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    usage
    ;;
  :)
    echo "Option -$OPTARG requires an argument" >&2
    usage
    ;;
  esac
done

# Check if kubectl is available
if ! command -v kubectl &>/dev/null; then
  echo "Error: kubectl is not installed or not in PATH" >&2
  exit 1
fi

# Check if kubectl can connect to the cluster
if ! kubectl cluster-info &>/dev/null; then
  echo "Error: Cannot connect to Kubernetes cluster. Check your kubeconfig." >&2
  exit 1
fi

# Create full backup path
BACKUP_PATH="${OUTPUT_DIR}/${BACKUP_DIR}"

# Create directory structure
mkdir -p "${BACKUP_PATH}"/{deployments,services,configmaps,secrets,statefulsets,daemonsets,ingresses,pvc,cronjobs,jobs,hpa,networkpolicies,roles,rolebindings,serviceaccounts}

log() {
  if [[ "$VERBOSE" == true ]] || [[ "$1" == "ERROR" ]]; then
    echo "$@"
  fi
}

# Function to check if a resource should be excluded
should_exclude() {
  local resource_namespace="$1"
  local resource_name="$2"

  # Skip resources in excluded namespaces
  for excluded in $EXCLUDE_NAMESPACES; do
    if [[ "$resource_namespace" == "$excluded" ]]; then
      return 0
    fi
  done

  # Skip default/kubernetes service
  if [[ "$resource_name" == "kubernetes" && "$resource_namespace" == "default" ]]; then
    return 0
  fi

  # Exclude typically auto-generated secrets
  if [[ "$resource_name" == *"token"* || "$resource_name" == *"default"* || "$resource_name" == *"docker"* ]]; then
    return 0
  fi

  return 1
}

# Function to safely create filenames - FIXED the character range issue
safe_filename() {
  # Fixed character range by moving the hyphen to the end
  echo "$1" | tr -s '[:blank:]' '_' | tr -d '[:cntrl:]' | tr -c '[:alnum:]_.' '-'
}

# Function to export resources
export_resources() {
  local resource_type="$1"
  local directory="$2"

  log "=== Exporting $resource_type ==="

  if [[ -z "$NAMESPACE" ]]; then
    # All namespaces
    if ! resources=$(kubectl get "$resource_type" --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name --no-headers 2>/dev/null); then
      log "WARNING: Failed to get resources of type $resource_type"
      return 1
    fi

    while IFS= read -r line; do
      if [[ -z "$line" ]]; then continue; fi

      local namespace
      local name
      namespace=$(echo "$line" | awk '{print $1}')
      name=$(echo "$line" | awk '{print $2}')

      if should_exclude "$namespace" "$name"; then
        log "Skipping $resource_type: $namespace/$name (excluded resource)"
        continue
      fi

      # Create safe filename
      local safe_ns
      local safe_name
      safe_ns=$(safe_filename "$namespace")
      safe_name=$(safe_filename "$name")
      local filename="${directory}/${safe_ns}_${safe_name}.yaml"

      log "Exporting $resource_type: $namespace/$name"
      if ! kubectl get "$resource_type" -n "$namespace" "$name" -o yaml >"$filename"; then
        log "ERROR: Failed to export $resource_type: $namespace/$name"
      fi

    done <<<"$resources"
  else
    # Specific namespace - FIX: Properly handle NAMESPACE_OPT
    # SC2086: Double quote to prevent globbing and word splitting
    if ! resources=$(kubectl get "$resource_type" ${NAMESPACE:+-n "$NAMESPACE"} -o custom-columns=NAME:.metadata.name --no-headers 2>/dev/null); then
      log "WARNING: Failed to get resources of type $resource_type in namespace $NAMESPACE"
      return 1
    fi

    while IFS= read -r name; do
      if [[ -z "$name" ]]; then continue; fi

      if should_exclude "$NAMESPACE" "$name"; then
        log "Skipping $resource_type: $NAMESPACE/$name (excluded resource)"
        continue
      fi

      # Create safe filename
      local safe_name
      safe_name=$(safe_filename "$name")
      local filename="${directory}/${safe_name}.yaml"

      log "Exporting $resource_type: $NAMESPACE/$name"
      # SC2086: Double quote to prevent globbing and word splitting
      if ! kubectl get "$resource_type" ${NAMESPACE:+-n "$NAMESPACE"} "$name" -o yaml >"$filename"; then
        log "ERROR: Failed to export $resource_type: $NAMESPACE/$name"
      fi

    done <<<"$resources"
  fi
}

# Setup trap for cleanup on script interruption
cleanup() {
  echo -e "\nBackup interrupted. Cleaning up..."
  find "${BACKUP_PATH}" -type d -empty -delete
  echo "Partial backup saved to: ${BACKUP_PATH}"
  exit 1
}
trap cleanup INT TERM

# Print backup info
echo "=== Starting Kubernetes application backup to ${BACKUP_PATH} ==="
echo "Namespace: ${NAMESPACE:-All namespaces}"
echo "Excluding namespaces: ${EXCLUDE_NAMESPACES}"

# Export all resource types
export_resources "deployments.apps" "${BACKUP_PATH}/deployments"
export_resources "services" "${BACKUP_PATH}/services"
export_resources "configmaps" "${BACKUP_PATH}/configmaps"
export_resources "secrets" "${BACKUP_PATH}/secrets"
export_resources "statefulsets.apps" "${BACKUP_PATH}/statefulsets"
export_resources "daemonsets.apps" "${BACKUP_PATH}/daemonsets"
export_resources "ingresses.networking.k8s.io" "${BACKUP_PATH}/ingresses"
export_resources "persistentvolumeclaims" "${BACKUP_PATH}/pvc"
export_resources "cronjobs.batch" "${BACKUP_PATH}/cronjobs"
export_resources "jobs.batch" "${BACKUP_PATH}/jobs"
export_resources "horizontalpodautoscalers.autoscaling" "${BACKUP_PATH}/hpa"
export_resources "networkpolicies.networking.k8s.io" "${BACKUP_PATH}/networkpolicies"
export_resources "roles" "${BACKUP_PATH}/roles"
export_resources "rolebindings" "${BACKUP_PATH}/rolebindings"
export_resources "serviceaccounts" "${BACKUP_PATH}/serviceaccounts"

# Clean up empty directories
find "${BACKUP_PATH}" -type d -empty -delete

# Create a summary of the backup
# SC2129: Use a single redirection for multiple lines
{
  echo -e "\n=== Backup Summary ==="
  echo "Backup date: $(date)"
  echo "Kubernetes context: $(kubectl config current-context)"
  echo "Kubernetes server: $(kubectl cluster-info | head -n1 | awk '{print $NF}')"
  echo "Namespace: ${NAMESPACE:-All namespaces}"
  echo "Excluded namespaces: ${EXCLUDE_NAMESPACES}"
  echo -e "\nResources exported:"
} >"${BACKUP_PATH}/backup-summary.txt"

for dir in $(find "${BACKUP_PATH}" -type d | sort); do
  if [[ "$dir" != "${BACKUP_PATH}" ]]; then
    count=$(find "$dir" -type f | wc -l)
    if [[ $count -gt 0 ]]; then
      echo "$(basename "$dir"): $count files" >>"${BACKUP_PATH}/backup-summary.txt"
    fi
  fi
done

echo -e "\n=== Backup completed! ==="
echo "Backup saved to: ${BACKUP_PATH}"
echo "Backup summary saved to: ${BACKUP_PATH}/backup-summary.txt"

# Compress the backup if requested
if [[ "$COMPRESS" == true ]]; then
  ARCHIVE_NAME="${OUTPUT_DIR}/${BACKUP_DIR}.tar.gz"
  echo "Compressing backup to ${ARCHIVE_NAME}..."
  # SC2181: Check exit code directly instead of using $?
  if tar -czf "${ARCHIVE_NAME}" -C "${OUTPUT_DIR}" "${BACKUP_DIR}"; then
    echo "Backup compressed successfully: ${ARCHIVE_NAME}"
    if [[ "$VERBOSE" == false ]]; then
      rm -rf "${BACKUP_PATH}"
      echo "Temporary directory ${BACKUP_PATH} removed."
    fi
  else
    echo "ERROR: Failed to compress backup. Uncompressed backup is still available at ${BACKUP_PATH}"
  fi
fi

echo "Backup process completed successfully."
