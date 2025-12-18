## Run

```sh
kubectl run temp-pod --image=busybox --rm -it --restart=Never -- nslookup echo-server.echo-server.svc.cluster.local
```

## Port Forward

```sh
kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 8080:80
```

## Wait

````sh
```sh
kubectl wait --namespace ingress-nginx \
 --for=condition=ready pod \
 --selector=app.kubernetes.io/component=controller \
 --timeout=120s
````

## Ingress

### Create an ingress

```sh
kubectl create ingress demo --class=nginx --rule="www.demo.io/*=demo:80"
```

```sh
kubectl create ingress demo --class=nginx --rule www.demo.io/=demo:80 \
```

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.3/deploy/static/provider/aws/deploy.yaml
```

### Bare metal

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.3/deploy/static/provider/baremetal/deploy.yaml
```

### Testing

```sh
kcurl http://librechat-librechat.librechat.svc.cluster.local:3080
```
