echo '
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
  name: ${GENERIC}
  namespace: default
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /${GENERIC}(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: ${GENERIC}
            port: 
              number: 80
' | GENERIC=mypath envsubst | kubectl create -f -
