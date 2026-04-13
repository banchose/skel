deploy-pisal-onprem() {
  cd ~/hrigit/Kubernetes/pisal/newprod/ || {
    printf 'Cannot cd to dir\n' >&2
    return 1
  }
  git pull || return 1
  grep 'image:' ./pisal-deploy-newprod.yaml
  read -r -p "Apply? (y/N): "
  [[ ${REPLY} =~ ^[Yy]$ ]] || {
    printf 'Cancelled.\n'
    return 0
  }
  kubectl apply --context Prod-Admin@Prod -f ./pisal-deploy-newprod.yaml
}

deploy-pisal-awsweb() {
  cd ~/hrigit/Kubernetes/pisal/awswebprod/ || {
    printf 'Cannot cd to dir\n' >&2
    return 1
  }
  git pull || return 1
  grep 'image:' ./pisal-deploy-awswebprod.yaml
  read -r -p "Apply? (y/N): "
  [[ ${REPLY} =~ ^[Yy]$ ]] || {
    printf 'Cancelled.\n'
    return 0
  }
  kubectl apply --context arn:aws:eks:us-east-1:315633532929:cluster/EksProd -f ./pisal-deploy-awswebprod.yaml
}
deploy-pisalapi-awsweb() {
  cd ~/hrigit/Kubernetes/pisalapi/awswebprod/ || {
    printf 'Cannot cd to dir\n' >&2
    return 1
  }
  git pull || return 1
  grep 'image:' ./pisalapi-deploy-awswebprod.yaml
  read -r -p "Apply? (y/N): "
  [[ ${REPLY} =~ ^[Yy]$ ]] || {
    printf 'Cancelled.\n'
    return 0
  }
  kubectl apply --context arn:aws:eks:us-east-1:315633532929:cluster/EksProd -f ./pisalapi-deploy-awswebprod.yaml
}

deploy-pisalapi-onprem() {
  cd ~/hrigit/Kubernetes/pisalapi/newprod/ || {
    printf 'Cannot cd to dir\n' >&2
    return 1
  }
  git pull || return 1
  grep 'image:' ./pisalapi-deploy-newprod.yaml
  read -r -p "Apply? (y/N): "
  [[ ${REPLY} =~ ^[Yy]$ ]] || {
    printf 'Cancelled.\n'
    return 0
  }
  kubectl apply --context Prod-Admin@Prod -f ./pisalapi-deploy-newprod.yaml
}
