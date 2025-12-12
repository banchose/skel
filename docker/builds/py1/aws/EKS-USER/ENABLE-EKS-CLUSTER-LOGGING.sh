#  kubectl get  configmap aws-auth -n kube-system  -o yaml
#  Note the "assumed-role" for eks:developer
apiVersion: v1
data:
mapRoles: |
  - groups:
- system:bootstrappers
- system:nodes
rolearn: arn:aws:iam::405350004483:role/HRI-BIGEKSALB-rEksNodeInstanceRole-SPBSyWhYeoDe
username: system:node:{{EC2PrivateDNSName}}
- groups:
- eks:developer
rolearn: arn:aws:iam::405350004483:role/AWSReservedSSO_EKSLogsPermissionSet_641e07934445cd33
username: deleteme1
mapUsers: |
  - groups:
- eks:developer
userarn: arn:aws:sts::405350004483:assumed-role/AWSReservedSSO_EKSLogsPermissionSet_641e07934445cd33/deleteme1
username: deleteme1
kind: ConfigMap
metadata:
creationTimestamp: "2025-03-04T19:11:19Z"
name: aws-auth
namespace: kube-system
resourceVersion: "5861853"
