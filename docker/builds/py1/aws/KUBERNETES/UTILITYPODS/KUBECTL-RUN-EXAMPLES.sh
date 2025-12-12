exit 1

# - **Without `--command`**: Arguments are passed to the image's existing entrypoint
# - **With `--command`**: The arguments completely replace the image's command/entrypoint

# WORKS!

kubectl run -it curl-1 --rm --restart=Never --image=curlimages/curl --command -- curl --version
# SAME AS
kubectl run -it curl-1 --rm --restart=Never --image=curlimages/curl -- --version

kubectl run --image busybox --rm --restart=Never --attach test -- date

kubectl run -it alpine-test --image=alpine --restart=Never --rm --command -- ls
kubectl run -it curl-1 --rm --restart=Never --image=bash:latest -- -c 'for i in {1..10};do echo "$i";done'
