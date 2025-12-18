Perfect! Now I can see the exact issue. The pod can't be scheduled because it's looking for a node with the label `ingress-ready=true`, but your Kind node doesn't have this label.

**The Problem:**

```
Node-Selectors:              ingress-ready=true
                             kubernetes.io/os=linux
```

**The Error:**

```
1 node(s) didn't match Pod's node affinity/selector
```

## Solution: Label your Kind node

First, check your node name:

```bash
kubectl get nodes
```

Then add the required label to your Kind node:

```bash
kubectl label node <your-node-name> ingress-ready=true
```

For Kind, the node name is usually something like `kind-control-plane`, so it would be:

```bash
kubectl label node kind-control-plane ingress-ready=true
```

## Alternative One-Liner (if you have only one node):

```bash
kubectl label nodes $(kubectl get nodes -o name | cut -d/ -f2) ingress-ready=true
```

## Verify the Fix:

After adding the label, the pod should start scheduling immediately:

```bash
kubectl get pods -n ingress-nginx -w
```

You should see the controller pod transition from `Pending` → `ContainerCreating` → `Running`.

## Check the Label Was Applied:

```bash
kubectl get nodes --show-labels | grep ingress-ready
```

Once the ingress controller pod is running and ready (1/1), your admission webhook will work and you'll be able to create ingresses successfully!

This is a very common issue with Kind clusters because the standard NGINX ingress controller manifest expects nodes to be explicitly labeled as ingress-ready, but Kind doesn't do this by default.
