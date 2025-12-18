# Troubleshooting Kubernetes

## USE exec TO TEST: Simple floating bash container and re-exec

```sh
kubectl run bash-tmp --image=bash -- bash -c 'while true;do echo "$(date)";sleep 10;done'
kubectl exec bash-tmp  -- wget -O- 10.244.2.25:80
```

## Trace through service connections

Find the pod

```sh
kubectl get pods -o wide
```

Check the service at the pod port

```sh
kubectl exec bash-tmp  -- wget -O- 10.244.2.25
```

Find the service

```sh
kubectl get svc -A
```

Find Cluster-IP and Ports: ContainerPort:NodePort
and test the service

```sh
kubectl run my-test --image=bash --restart=Never --attach --rm -- wget -O- 10.244.2.25:"${ContainerPort}"
```

## Start a bash prompt

```sh
kubectl run -it bash-tmp --image=bash
```

## Start a nginx pod

```sh
kubectl run nginx --image=nginx
```

## Start a hazelcast pod and set environment variables "DNS_DOMAIN=cluster" and "POD_NAMESPACE=default" in the container

```sh
kubectl run hazelcast --image=bash --env="DNS_DOMAIN=cluster" --env="POD_NAMESPACE=default"
```

## Start a nginx pod, but overload the spec with a partial set of values parsed from JSON

```sh
kubectl run nginx --image=nginx --overrides='{ "apiVersion": "v1", "spec": { ... } }'
```

## Start a busybox pod and keep it in the foreground, don't restart it if it exits

```sh
kubectl run -i -t busybox --image=busybox --restart=Never
```
