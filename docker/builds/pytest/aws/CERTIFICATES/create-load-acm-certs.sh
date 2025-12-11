#!/usr/bin/env bash
# AWS Certificate Manager (ACM) Certificate Import Utility
# This script imports SSL/TLS certificates into AWS Certificate Manager

# Enable strict mode
set -euo pipefail

# Configurable variables
LEAF_CERT="star_healthresearch_org.crt"
PRIVATE_KEY="star_healthresearch_org.key"
INTERMEDIATE_CERT="DigiCertCA.crt"
ROOT_CERT="TrustedRoot.crt"
CHAIN_FILE="fullchain.pem"

# AWSProfile=production
AWSProfile=dev

# Function to validate prerequisites
function validate_prerequisites() {
  local missing_files=()

  # Check required files exist
  for file in "${LEAF_CERT}" "${PRIVATE_KEY}" "${INTERMEDIATE_CERT}" "${ROOT_CERT}"; do
    if [[ ! -f "${file}" ]]; then
      missing_files+=("${file}")
    fi
  done

  # Report missing files and exit if any
  if ((${#missing_files[@]} > 0)); then
    echo "ERROR: The following required files are missing:" >&2
    for file in "${missing_files[@]}"; do
      echo " - ${file}" >&2
    done
    return 1
  fi

  # Validate AWS profile
  if [[ -z "${AWSProfile:-}" ]]; then
    echo "ERROR: AWSProfile environment variable is not set" >&2
    echo "Usage: AWSProfile=your-profile-name $0" >&2
    return 1
  fi

  # Check if the AWS profile exists
  if ! aws configure list-profiles 2>/dev/null | grep -q "^${AWSProfile}$"; then
    echo "WARNING: AWS profile '${AWSProfile}' may not exist in your AWS config" >&2
    echo "The import operation might fail if the profile is invalid" >&2
    # Not failing here as the profile might be valid in ways not detectable by this check
    sleep 2 # Give the user time to read the warning
  fi

  return 0
}

# Function to create fullchain certificate if needed
function prepare_fullchain_cert() {
  if [[ ! -f "${CHAIN_FILE}" ]]; then
    echo "Creating fullchain certificate file..."
    # Combining leaf, intermediate and root certificates
    cat "${LEAF_CERT}" "${INTERMEDIATE_CERT}" "${ROOT_CERT}" >"${CHAIN_FILE}"
    echo "Fullchain certificate created: ${CHAIN_FILE}"
  else
    echo "Using existing fullchain certificate: ${CHAIN_FILE}"
  fi
}

# Function to import certificate to ACM
function import_certificate() {
  echo "Importing certificate to AWS Certificate Manager..."

  # Store the import result for later use
  local import_result
  import_result=$(aws acm import-certificate \
    --certificate "fileb://${LEAF_CERT}" \
    --private-key "fileb://${PRIVATE_KEY}" \
    --certificate-chain "fileb://${CHAIN_FILE}" \
    --profile "${AWSProfile}" 2>&1) || {
    echo "ERROR: Failed to import certificate" >&2
    echo "${import_result}" >&2
    return 1
  }

  echo "Certificate successfully imported!"
  echo "${import_result}"

  # Extract and display the ARN for user reference
  if [[ "${import_result}" == *"CertificateArn"* ]]; then
    local arn
    arn=$(echo "${import_result}" | grep -o '"CertificateArn": "[^"]*"' | cut -d'"' -f4)
    echo "Certificate ARN: ${arn}"
  fi
}

# Function to list certificates
function list_certificates() {
  echo "Listing certificates in AWS Certificate Manager..."

  aws acm list-certificates \
    --profile "${AWSProfile}" \
    --max-items 10 || {
    echo "WARNING: Failed to list certificates" >&2
    return 0 # Non-fatal error
  }
}

# Main execution
function main() {
  # Enable command echoing if DEBUG is set
  if [[ -n "${DEBUG:-}" ]]; then
    set -x
  fi

  echo "Starting AWS certificate import process..."

  # Run the workflow
  validate_prerequisites || exit 1
  prepare_fullchain_cert
  import_certificate || exit 1
  list_certificates

  echo "Certificate import process completed!"
  return 0
}

# Execute main function
main "$@"
