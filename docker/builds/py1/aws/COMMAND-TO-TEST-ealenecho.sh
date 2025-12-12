#!/usr/bin/env bash
set -euo pipefail

EP=http://internal-k8s-default-awsingre-32ebfbcf83-1182275225.us-east-1.elb.amazonaws.com
curl -L -v -H "Host: ingo.healthresearch.org" "${EP}"/ealenecho
