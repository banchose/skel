# kubectl commands

## get

```sh
kubectl get pod mypod -o yaml | sed 's/\(image: myimage\):.*$/\1:v4/' | kubectl replace -f -
kubectl get deployment nginx-deployment --subresource=status
kubectl get pods -o json | jq -c 'paths|join(".")'
kubectl get nodes -o json | jq -c 'paths|join(".")'
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'
kubectl get pods --selector=app=cassandra -o jsonpath='{.items[*].metadata.labels.version}'
kubectl get configmap myconfig -o jsonpath='{.data.ca\.crt}'
kubectl get secret my-secret --template='{{index .data "key-name-with-dashes"}}'
kubectl get pods --field-selector=status.phase=Running
kubectl get node -o custom-columns='NODE_NAME:.metadata.name,STATUS:.status.conditions[?(@.type=="Ready")].status'
kubectl get secret my-secret -o go-template='{{range $k,$v := .data}}{{"### "}}{{$k}}{{" "}}{{$v|base64decode}}{{" "}}{{end}}'
kubectl get pods -o json | jq '.items[].spec.containers[].env[]?.valueFrom.secretKeyRef.name' | grep -v null | sort | uniq
kubectl get pods --all-namespaces -o jsonpath='{range .items[*].status.initContainerStatuses[*]}{.containerID}{" "}{end}' | cut -d/ -f3
```

```

```

## info

```sh
kubectl cluster-info
kubectl cluster-info dump
kubectl cluster-info dump --output-directory=/path/to/cluster-state
```

## resources

```sh
kubectl cluster-info dump --output-directory=/path/to/cluster-state
kubectl api-resources --namespaced=true
kubectl api-resources --namespaced=false
kubectl api-resources -o name
kubectl api-resources -o wide
kubectl api-resources --verbs=list,get
kubectl api-resources --api-group=extensions
```

## curl

```sh
kubectl run -it curl-1 --rm --restart=Never --image=curlimages/curl --image-pull-policy=Always --command -- curl --version
kubectl run -it curl-1 --rm --restart=Never --image=curlimages/curl --image-pull-policy=Never --command -- curl --version
```

## scale

```sh
kubectl scale --replicas=3 rs/foo
kubectl scale --replicas=3 -f foo.yaml
kubectl scale --current-replicas=2 --replicas=3 deployment/mysql
kubectl scale --replicas=5 rc/foo rc/bar rc/baz
```

## get

## delete

```sh
# delete pods and services with the names baz and foo
kubectl delete pod,service baz foo
#
kubectl delete pods,services -l name=myLabel
kubectl -n my-ns delete pod,svc --all
kubectl get pods -n mynamespace --no-headers=true | awk '/pattern1|pattern2/{print $1}' | xargs kubectl delete -n mynamespace pod
```

## apply / create

```sh
kubectl replace --force -f ./pod.json
kubectl apply -f ./my1.yaml -f ./my2.yaml
kubectl apply -f ./dir
kubectl apply -f https://example.com/manifest.yaml
kubectl expose rc nginx --port=80 --target-port=8000 # creates a service
kubectl create namespace my-namespace
kubectl create deployment nginx --image=nginx
kubectl create job hello --image=busybox:1.28 -- echo 'Hello World'
kubectl create cronjob hello --image=busybox:1.28 --schedule='*/1 * * * *' -- echo 'Hello World'
kubectl explain pods
```

## exec

```sh
kubectl exec my-pod -c my-container -- ls /
kubectl exec my-pod -- ls /
```

## Generate spec

```sh
kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
```

## Shell

```sh
kubectl run -i --tty busybox --image=busybox:1.28 -- sh
```

## Port-forward

```sh
kubectl port-forward -n kube-system ingress-nginx-controller-74cc87f964-7z6tt 10254:10254
kubectl port-forward deploy/my-deployment 5000:6000
kubectl port-forward svc/my-service 5000
kubectl port-forward svc/my-service 5000
```

## annotate

## copy files

```sh
kubectl cp /tmp/foo_dir my-pod:/tmp/bar_dir
kubectl cp /tmp/foo my-pod:/tmp/bar -c my-container
kubectl cp /tmp/foo my-namespace/my-pod:/tmp/bar
kubectl cp my-namespace/my-pod:/tmp/foo /tmp/bar
tar cf - /tmp/foo | kubectl exec -i -n my-namespace my-pod -- tar xf - -C /tmp/bar
kubectl exec -n my-namespace my-pod -- tar cf - /tmp/foo | tar xf - -C /tmp/bar
```

```sh
kubectl annotate pods my-pod icon-url=http://goo.gl/XXBTWq
```

## labels

```sh
kubectl label pods my-pod new-label- # Mind the - and it removes a label
kubectl label pods my-pod new-label=new-value --overwrite
kubectl label pods my-pod new-label=awesome
```

## logs

```sh
kubectl run my-test --image=bash --restart=Never --attach --rm -- echo "Hello World"
kubectl logs deploy/my-deployment -c my-container
kubectl logs deploy/my-deployment
```

## editing

```sh
KUBE_EDITOR="vim" kubectl edit svc/docker-registry
kubectl edit svc/docker-registry
```

## classify

```sh
kubectl get pod mypod -o yaml | sed 's/\(image: myimage\):.*$/\1:v4/' | kubectl replace -f -
kubectl get deployment nginx-deployment --subresource=status
kubectl get pods -o json | jq -c 'paths|join(".")'
kubectl get nodes -o json | jq -c 'paths|join(".")'
kubectl events --types=Warning
kubectl diff -f ./my-manifest.yaml
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'
kubectl get pods --selector=app=cassandra -o jsonpath='{.items[*].metadata.labels.version}'
kubectl get configmap myconfig -o jsonpath='{.data.ca\.crt}'
kubectl get secret my-secret --template='{{index .data "key-name-with-dashes"}}'
kubectl get pods --field-selector=status.phase=Running
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' && kubectl get nodes -o jsonpath="$JSONPATH" | grep "Ready=True"
kubectl get node -o custom-columns='NODE_NAME:.metadata.name,STATUS:.status.conditions[?(@.type=="Ready")].status'
kubectl get secret my-secret -o go-template='{{range $k,$v := .data}}{{"### "}}{{$k}}{{" "}}{{$v|base64decode}}{{" "}}{{end}}'
kubectl get pods -o json | jq '.items[].spec.containers[].env[]?.valueFrom.secretKeyRef.name' | grep -v null | sort | uniq
kubectl get pods --all-namespaces -o jsonpath='{range .items[*].status.initContainerStatuses[*]}{.containerID}{" "}{end}' | cut -d/ -f3
```

## patch

```sh
kubectl patch node k8s-node-1 -p '{"spec":{"unschedulable":true}}'
kubectl patch pod valid-pod -p '{"spec":{"containers":[{"name":"kubernetes-serve-hostname","image":"new image"}]}}'
kubectl patch pod valid-pod --type='json' -p='[{"op": "replace", "path": "/spec/containers/0/image", "value":"new image"}]'
kubectl patch deployment valid-deployment --type json -p='[{"op": "remove", "path": "/spec/template/spec/containers/0/livenessProbe"}]'
kubectl patch sa default --type='json' -p='[{"op": "add", "path": "/secrets/1", "value": {"name": "whatever" } }]'
kubectl patch deployment nginx-deployment --subresource='scale' --type='merge' -p '{"spec":{"replicas":2}}'
```
