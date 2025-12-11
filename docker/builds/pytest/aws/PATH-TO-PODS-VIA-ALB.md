# Troubleshooting Load Balancer to AWS ingress to pod pathing


## Find the Load Balancer endpoint(s)

- Mind the profile

```sh
aws elbv2 describe-load-balancers --query 'LoadBalancers[].DNSName' --profile test
```

## curl to test the ealenecho endpoint

- Mind the -H to set the Host:

```sh
EP=http://internal-k8s-default-awsingre-32ebfbcf83-1182275225.us-east-1.elb.amazonaws.com # example LB EP
curl -L -v -H "Host: ingo.healthresearch.org" "${EP}"/ealenecho | jq '.'
# check the EP IPs
nslookup "${EP}"
```
## Verify the `host` is correct as the LB sees it

- It will only get in this check `/ealenecho`  if the host is correct

```yaml
- host: ingo.healthresearch.org  # This is a host rule
     http:
       paths:
       - path: /ealenecho
```
### Check out what the listener thinks

```sh
ALB_ARN=$(aws elbv2 describe-load-balancers --names k8s-default-awsingre-32ebfbcf83 --query "LoadBalancers[0].LoadBalancerArn" --output text --profile test)

# 2. Get the listener ARNs for this ALB
LISTENER_ARNS=$(aws elbv2 describe-listeners --load-balancer-arn $ALB_ARN --query "Listeners[*].ListenerArn" --output text --profile test)

# 3. For each listener, get the rules
for LISTENER_ARN in $LISTENER_ARNS; do
  echo "Listener: $LISTENER_ARN"
  aws elbv2 describe-rules --listener-arn $LISTENER_ARN --profile test
doneALB_ARN=$(aws elbv2 describe-load-balancers --names k8s-default-awsingre-32ebfbcf83 --query "LoadBalancers[0].LoadBalancerArn" --output text --profile test)

# 2. Get the listener ARNs for this ALB
LISTENER_ARNS=$(aws elbv2 describe-listeners --load-balancer-arn $ALB_ARN --query "Listeners[*].ListenerArn" --output text --profile test)

# 3. For each listener, get the rules
for LISTENER_ARN in $LISTENER_ARNS; do
  echo "Listener: $LISTENER_ARN"
  aws elbv2 describe-rules --listener-arn $LISTENER_ARN --profile test
done
```
```
```
