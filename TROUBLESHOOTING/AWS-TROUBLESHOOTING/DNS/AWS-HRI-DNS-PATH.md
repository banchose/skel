# DNS

1. You are resolving agains Route53 at `.2` of Cidr
2. There are RAM Shared resolver rules (to the Org) from the Network account (--profile net)
3. You should be resolver rules to forward 3 domains
4. There resolver rules are associated with OUTBOUND endpoints
5. The rules forward to 10.1.100.100,10.1.100.101 (OVER SITE-TO-SITE VPN to onprem)

```sh
aws route53resolver list-resolver-rules --profile net
aws route53resolver list-resolver-endpoints --profile net
```

This creates the RAM share

```sh
aws ram create-resource-share \
  --name "DNS-Resolver-Rules-Share" \
  --resource-arns \
    "arn:aws:route53resolver:us-east-1:211262586138:resolver-rule/rslvr-rr-30da02c1c69d4f659" \
    "arn:aws:route53resolver:us-east-1:211262586138:resolver-rule/rslvr-rr-4ded99599e8e47228" \
    "arn:aws:route53resolver:us-east-1:211262586138:resolver-rule/rslvr-rr-655620a3969d4331b" \
  --principals "arn:aws:organizations::211262586138:organization/o-lc7xr8uwdh" \
  --permission-arns "arn:aws:ram::aws:permission/AWSRAMDefaultPermissionRoute53ResolverRule" \
  --profile net
```

This associates the resolver rule with the whole Org from net
```sh
aws ram associate-resource-share \
  --resource-share-arn "arn:aws:ram:us-east-1:211262586138:resource-share/share-id-from-previous-command" \
  --principals "arn:aws:organizations::211262586138:organization/o-lc7xr8uwdh" \
  --profile net
```

Associat4e shared resolver rule with the accounts Vpc

```sh

# For the reverse lookup zone
aws route53resolver associate-resolver-rule \
  --resolver-rule-id "rslvr-rr-30da02c1c69d4f659" \
  --vpc-id "vpc-id-in-test-account" \
  --name "Reverse-Lookup-Association" \
  --profile test

# For healthresearch.org
aws route53resolver associate-resolver-rule \
  --resolver-rule-id "rslvr-rr-4ded99599e8e47228" \
  --vpc-id "vpc-id-in-test-account" \
  --name "Healthresearch-DNS-Association" \
  --profile test
```

# For corp.healthresearch.org
aws route53resolver associate-resolver-rule \
  --resolver-rule-id "rslvr-rr-655620a3969d4331b" \
  --vpc-id "vpc-id-in-test-account" \
  --name "Corp-Healthresearch-DNS-Association" \
  --profile test


```sh
aws route53resolver create-resolver-rule \
  --creator-request-id "$(date +%s-%N)" \
  --domain-name "1.10.in-addr.arpa." \
  --name "PrivateHostedZoneForwardingRuleHriAdDnsRev" \
  --resolver-endpoint-id "rslvr-out-517cb5d9373945358" \
  --rule-type FORWARD \
  --target-ips Ip=10.1.100.100,Port=53,Protocol=Do53 Ip=10.1.100.101,Port=53,Protocol=Do53 \
  --region us-east-1 \
  --profile net

aws route53resolver create-resolver-rule \
  --creator-request-id "$(date +%s-%N)" \
  --domain-name "corp.healthresearch.org." \
  --name "PrivateHostedZoneForwardingRuleHriAdDns" \
  --resolver-endpoint-id "rslvr-out-9f075b20409140bc8" \
  --rule-type FORWARD \
  --target-ips Ip=10.1.100.100,Port=53,Protocol=Do53 Ip=10.1.100.101,Port=53,Protocol=Do53

aws route53resolver create-resolver-rule \
  --creator-request-id "$(date +%s-%N)" \
  --domain-name "healthresearch.org." \
  --name "PrivateHostedZoneForwardingRuleHealthresearchDns" \
  --resolver-endpoint-id "rslvr-out-9f075b20409140bc8" \
  --rule-type FORWARD \
  --target-ips Ip=10.1.100.100,Port=53,Protocol=Do53 Ip=10.1.100.101,Port=53,Protocol=Do53 \
  --region us-east-1 \
  --profile net

aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-08b2d4bc8cbae9302" "Name=availability-zone,Values=us-east-1a,us-east-1c" \
  --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock]' \
  --output table \
  --profile net

```

