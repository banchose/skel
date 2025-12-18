# Troubleshooting Certificates Certificates


## Get you kubectl environment

```sh
aws eks update-kubeconfig --name <cluste_name> --region us-east-1 --profile test
```

## Check aws-load-balance-controller

- The load balancer pods should be running

```sh
kubectl get -n kube-system pods
```

## Get ALB DNS Endpoint

```sh
kubectl get ingress my-internal-ingress \ 
-o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Get certificate

```sh
openssl s_client -connect internal-k8s-default-myintern-84be887eda-774944693.us-east-1.elb.amazonaws.com:443 -servername service-name.healthresearch.org
```

## ingress

```sh
kubectl get ingress
kubectl describe ingress <ingress>
```

## List Certificates

```sh
aws acm request-certificate \
  --domain-name internal.example.com \
  --validation-method DNS \
  --region us-east-1 \
  --profile test
```

## SSL/TLS Ingress Anotation

```yaml
apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: my-internal-ingress
     annotations:
       alb.ingress.kubernetes.io/scheme: internal
       alb.ingress.kubernetes.io/target-type: ip
       alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012  # Replace with your actual ARN
       alb.ingress.kubernetes.io/ssl-redirect: '443'
       alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
   spec:
     ingressClassName: alb
     rules:
     - host: internal.example.com
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: my-service
               port:
                 number: 80
```
