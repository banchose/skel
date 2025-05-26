

# aws configure sso --profile <profile>
#
# aws eks update-kubeconfig --name rEksCluster --profile test
# kubectl get pods -o wide
# kubectl exec -it nginx-netshoot-7f9c6957f8-kr8q6 -c netshoot -- /bin/bash
#

## Packages and Helm

### k9s (easy to see logs)

wget https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb && sudo apt install ./k9s_linux_amd64.deb && rm k9s_linux_amd64.deb

### stern (easy to see logs and activity)

#### Install

```
go install github.com/stern/stern@latest
```

- puts in `~/go/bin`

#### Stern examples

```sh
# Completions
source <(stern --completion=bash)

# Run in a container
docker run ghcr.io/stern/stern --version
```
# Tail all logs from all namespaces
stern . --all-namespaces
# Only shoe from pods not ready
stern . --condition=ready=false --tail=0
# Tail the kube-system namespace without printing any prior logs
stern . -n kube-system --tail 0
# Tail the gateway container running inside of the envvars pod on staging
stern envvars --context staging --container gateway
# Tail the staging namespace excluding logs from istio-proxy container
stern -n staging --exclude-container istio-proxy .
# Tail the kube-system namespace excluding logs from kube-apiserver pod
stern -n kube-system --exclude-pod kube-apiserver .
# Show auth activity from 15min ago with timestamps
stern auth -t --since 15m
# Show all logs of the last 5min by time, sorted by time
stern --since=5m --no-follow --only-log-lines -A -t . | sort -k4
```
```
