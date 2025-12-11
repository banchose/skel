echo '
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
  name: echo-server
  namespace: default
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /echo(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: echo-server
            port: 
              number: 80
' | kubectl create -f -
