kubectl get ingress my-internal-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
