## Verify
aws ec2 describe-security-groups \
  --group-ids sg-07b7ba2b5784fbbea \
  --query 'SecurityGroups[0].IpPermissions'

## Delete
aws ec2 revoke-security-group-ingress \
  --group-id sg-07b7ba2b5784fbbea \
  --protocol tcp \
  --port 443 \
  --cidr 10.0.0.0/8 \
  --region us-east-1 \
  --profile test

aws ec2 revoke-security-group-ingress \
  --group-id sg-07b7ba2b5784fbbea \
  --security-group-rule-ids sgr-049a359db23d34467 \
  --region us-east-1 \
  --profile test

## Add
aws ec2 authorize-security-group-ingress \
  --group-id sg-07b7ba2b5784fbbea \
  --protocol tcp \
  --port 443 \
  --cidr 10.0.0.0/8 \
  --region us-east-1 \
  --profile test
