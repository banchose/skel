#!/usr/bin/env bash
set -euo pipefail

# This will reach out to 172.22.x.2 for Route53 nslookup
# That will forward (via ram shared resolver rule) healthresearch.org to
# aws route53resolver list-resolver-rules    --output table   --profile test   --no-cli-pager
# both corp.healthresearch.org and healthresearch.org are forwarded to MS AD DNS
# That forwared to alb-prd-zdns-1.dz.corp.healthresearch.org 10.1.201.104
# via OUTBOUND endpoints
# OVER THE SITE-TO-SITE-VPN ONLY!!!

DNSName='internal-k8s-default-awsingre-32ebfbcf83-1182275225.us-east-1.elb.amazonaws.com'
EP="http://${DNSName}"

echo ""
echo ""
echo ""
echo "###############################################"
echo ""
echo ""
echo " Testing enpoint resolves to AWS IP "
echo ""
echo ""
echo "###############################################"
echo ""
echo ""
echo ""

nslookup "${DNSName}"

echo ""
echo ""
echo ""
echo "###############################################"
echo ""
echo ""
echo " Testing ingo.healthresearch.org/"
echo ""
echo ""
echo "###############################################"
echo ""
echo ""
echo ""

curl -L -v -H "Host: ingo.healthresearch.org" "${EP}"

echo ""
echo ""
echo ""
echo "###############################################"
echo ""
echo ""
echo " Testing ingo.healthresearch.org/ealenecho"
echo ""
echo ""
echo "###############################################"
echo ""
echo ""
echo ""

curl -L -v -H "Host: ingo.healthresearch.org" "${EP}"/ealenecho

echo ""
echo ""
echo ""
echo "###############################################"
echo ""
echo ""
echo " Testing ingo.healthresearch.org/pisal"
echo ""
echo ""
echo "###############################################"
echo ""
echo ""
echo ""

# Health Research welcome page
curl -L -v -H "Host: ingo.healthresearch.org" "${EP}"/pisal
