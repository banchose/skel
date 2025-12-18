exit 1

openssl s_client -connect internal-k8s-default-myintern-84be887eda-774944693.us-east-1.elb.amazonaws.com:443 -servername service-name.healthresearch.org

aws elbv2 describe-listeners \
  --load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:405350004483:loadbalancer/app/k8s-default-myintern-84be887eda/5ce43dc503a71286 \
  --query "Listeners[?Port==443].Certificates"

curl -vk https://internal-k8s-default-myintern-84be887eda-774944693.us-east-1.elb.amazonaws.com \
  -H "Host: service-name.healthresearch.org"
