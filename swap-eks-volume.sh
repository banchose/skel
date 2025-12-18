#!/usr/bin/env bash

set -xueo pipefail

# AWS Backup → EBS Volume → PV → PVC → Pod

# Create a tiny pod with the restored volume mounted
kubectl run volume-test --image=busybox -n openwebui \
  --overrides='{"spec":{"volumes":[{"name":"data","persistentVolumeClaim":{"claimName":"restored-pvc"}}],"containers":[{"name":"busybox","image":"busybox","command":["sleep","3600"],"volumeMounts":[{"name":"data","mountPath":"/data"}]}]}}'

# Check if webui.db exists and is readable
kubectl exec -n openwebui volume-test -- ls -lh /data/
kubectl exec -n openwebui volume-test -- sqlite3 /data/webui.db "SELECT count(*) FROM users;"
