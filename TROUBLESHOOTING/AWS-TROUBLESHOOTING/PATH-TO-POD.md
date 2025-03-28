1. look for the host in the host name in the aws-ingress

## Find the host in the ingress

```sh
aws eks update-kubeconfig  --profile test
kubectl describe ingress aws-ingress
kubectl get ingress aws-ingress -o yaml
```
```yaml
- host: ingo.healthresearch.org  # This is a host rule
     http:
       paths:
       - path: /ealenecho
```

Find what the Load Balancer listener thinks
```sh
aws elbv2 describe-load-balancers --output text --query 'LoadBalancers[].LoadBalancerName' --profile test

ALB_ARN=$(aws elbv2 describe-load-balancers --names k8s-default-awsingre-32ebfbcf83 --query "LoadBalancers[0].LoadBalancerArn" --output text --profile test)

# 2. Get the listener ARNs for this ALB
LISTENER_ARNS=$(aws elbv2 describe-listeners --load-balancer-arn $ALB_ARN --query "Listeners[*].ListenerArn" --output text --profile test)

# 3. For each listener, get the rules
for LISTENER_ARN in $LISTENER_ARNS; do
  echo "Listener: $LISTENER_ARN"
  aws elbv2 describe-rules --listener-arn $LISTENER_ARN --profile test
done
```

##

### use

  ```

  ```
```
```
