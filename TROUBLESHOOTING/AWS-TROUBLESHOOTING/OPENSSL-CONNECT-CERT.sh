#!/usr/bin/env bash

set -euo pipefail

SITE=internal-k8s-default-ealenech-7a3adaf293-688301228.us-east-1.elb.amazonaws.com
PORT=443 #  MIND THIS

echo | openssl s_client -connect "${SITE}":"${PORT}"
