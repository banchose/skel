alias killopenwebui='fuser -k 8080/tcp;fuser -k 4000/tcp;fuser -k 8000/tcp;fuser -k 8001/tcp;fuser -k 8002/tcp;fuser -k 8003/tcp'

alias getrag="kubectl logs -f --context arn:aws:eks:us-east-1:405350004483:cluster/EksTest statefulset/open-webui -n openwebui | grep vector"

alias getwebui="aws s3 cp s3://openwebui-db-backups/webui.db ~/Downloads/webui.db-"$(date +%s)" --region us-east-1 --profile test"
