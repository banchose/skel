needs to be set per node

Kubernetes: Ah, I see the confusion! When you create a kind cluster with `extraPortMappings`, there's initially **NO service listening on port 80** inside the Kubernetes cluster. The port mapping just creates a **tunnel waiting for something to use it**.

## What's Actually Happening

1. **After cluster creation with extraPortMappings:**

```bash
# This will fail - nothing listening on port 80 yet
curl localhost:80
# Connection refused
```

2. **The port mapping exists but points to nowhere:**

```bash
# Check what's listening in the kind node
docker exec -it kind-control-plane netstat -tlnp | grep :80
# You'll see nothing or just the kernel listening
```

## The Service Gets Created When You Install an Ingress Controller

The key is in this part of the documentation you provided:

```bash
# This creates the actual service that will listen on port 80
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
```

Let's see what this ingress controller deployment creates:

```bash
# After installing ingress-nginx, check what's running
kubectl get pods -n ingress-nginx
kubectl get services -n ingress-nginx

# This will show an ingress-nginx-controller service
NAME                                 TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.96.33.233   <pending>     80:31234/TCP,443:30567/TCP   1m
```

## How It All Connects

1. **extraPortMappings** creates: `localhost:80 → kind-node:80` (tunnel)
2. **Ingress controller** creates: A process listening on port 80 inside the kind node
3. **Together they provide**: `localhost:80 → kind-node:80 → ingress-controller → kubernetes services`

## Test This Yourself

```bash
# 1. Create cluster with port mapping
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
EOF

# 2. Test - this fails (nothing listening)
curl localhost:80
# Connection refused

# 3. Install ingress controller
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

# 4. Wait for it to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# 5. Now test - this works!
curl localhost:80
# You'll get a 404 from nginx (which means nginx is running!)
```

## What's Actually Listening

After installing the ingress controller:

```bash
# Check what's listening in the kind node
docker exec -it kind-control-plane netstat -tlnp | grep :80
# You'll see something like:
# tcp  0  0  0.0.0.0:80  0.0.0.0:*  LISTEN  1234/nginx
```

So the "service" that ends up listening on port 80 is the **nginx ingress controller** that gets deployed later. The `extraPortMappings` is just preparing the infrastructure for that service to be accessible from your host machine!
