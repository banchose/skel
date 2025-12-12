#!/usr/bin/env bash

set -euo pipefail

# Test pisal
for site in web ringo orbit; do
  echo
  echo "######################################################################"
  echo "Testing https://${site}".healthresearch.org/pisal
  echo "######################################################################"
  echo
  curl --no-progress-meter \
    --max-time 5 \
    https://"${site}".healthresearch.org/pisal
done

# Test pisalapi
for site in web ringo orbit; do
  echo
  echo "######################################################################"
  echo "Testing https://${site}".healthresearch.org/pisalapi/vi/apps/status
  echo "######################################################################"
  echo
  curl --no-progress-meter \
    --max-time 5 \
    https://"${site}".healthresearch.org/pisalapi/api/v1/app/status
done
