#!/usr/bin/env bash
set -euo pipefail

KUBECONTEXT="Prod-Admin@Prod"
DEPLOYFILE="$HOME/hrigit/Kubernetes/pisal/newprod/pisal-deploy-newprod.yaml"
# DEPLOYFILE="$HOME/hrigit/Kubernetes/pisalapi/newprod/pisalapi-deploy-newprod.yaml"

####################################################################
# KUBECONTEXT="Prod-Admin@Prod"
# DEPLOYFILE="$HOME/hrigit/Kubernetes/pisal/newprod/pisal-deploy-newprod.yaml"
#
# KUBECONTEXT="Prod-Admin@Prod"
# DEPLOYFILE="$HOME/hrigit/Kubernetes/pisal/newprod/pisal-deploy-newprod.yaml"
#
# KUBECONTEXT="Prod-Admin@Prod"
# DEPLOYFILE="$HOME/hrigit/Kubernetes/pisal/newprod/pisal-deploy-newprod.yaml"
#
# KUBECONTEXT="Prod-Admin@Prod"
# DEPLOYFILE="$HOME/hrigit/Kubernetes/pisal/newprod/pisal-deploy-newprod.yaml"
####################################################################

echo "=== Step 1: Navigate to repository ==="
cd ~/hrigit/Kubernetes || {
  echo "ERROR: failed to cd to ~/hrigit/Kubernetes"
  exit 1
}
echo "✓ Currently in: $PWD"

cd pisal/newprod || {
  echo "ERROR: failed to cd to pisal/newprod"
  exit 1
}
echo "✓ Currently in: $PWD"

echo -e "\n=== Step 2: Update from Git ==="
git fetch --prune
git pull

echo -e "\n=== Step 3: Switch kubectl context ==="
kubectl config use-context "${KUBECONTEXT}" || {
  echo "ERROR: Failed switching to context ${KUBECONTEXT}"
  exit 1
}
echo "Context: $(kubectl config current-context)"
echo "Cluster: $(kubectl config view --minify -o jsonpath='{.clusters[0].name}')"

echo -e "\n=== Step 4: Validate deployment file ==="
if [[ ! -f "${DEPLOYFILE}" ]]; then
  echo "ERROR: Deployment file not found: ${DEPLOYFILE}"
  exit 1
fi
echo "✓ File exists: ${DEPLOYFILE}"

echo -e "\n=== Step 5: Show what will change (kubectl diff) ==="
echo "Running: kubectl diff -f ${DEPLOYFILE}"
if kubectl diff -f "${DEPLOYFILE}"; then
  echo -e "\nNo changes detected - deployment matches cluster state"
  NO_CHANGES=true
else
  DIFF_EXIT=$?
  if [[ $DIFF_EXIT -eq 1 ]]; then
    echo -e "\nChanges detected above (exit code 1 is normal for diff)"
    NO_CHANGES=false
  else
    echo -e "\nERROR: kubectl diff failed with exit code $DIFF_EXIT"
    exit 1
  fi
fi

echo -e "\n=== Step 6: Server-side dry run validation ==="
kubectl apply --dry-run=server -f "${DEPLOYFILE}" || {
  echo "ERROR: Server-side validation failed"
  exit 1
}
echo "Server validation passed"

if [[ "${NO_CHANGES}" == "true" ]]; then
  echo -e "\n=== Summary: No changes to apply ==="
  exit 0
fi

echo -e "\n=== Step 7: Confirm before applying ==="
read -p "Apply these changes to PRODUCTION? (yes/NO): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "❌ Deployment cancelled"
  exit 0
fi

echo -e "\n=== Step 8: Applying changes ==="
kubectl apply -f "${DEPLOYFILE}"

echo -e "\n=== Step 9: Monitor rollout ==="
# Extract deployment name from YAML
DEPLOYMENT_NAME=$(grep -E '^\s*name:' "${DEPLOYFILE}" | head -1 | awk '{print $2}')
if [[ -n "${DEPLOYMENT_NAME}" ]]; then
  echo "Watching rollout status for: ${DEPLOYMENT_NAME}"
  kubectl rollout status deployment/"${DEPLOYMENT_NAME}" --timeout=5m
else
  echo "Could not extract deployment name for rollout monitoring"
fi

echo -e "\n✅ Deployment complete!"
