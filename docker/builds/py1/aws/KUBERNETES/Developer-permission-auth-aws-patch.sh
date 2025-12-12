#!/usr/bin/env bash

set -xeuo pipefail

kubectl patch configmap aws-auth -n kube-system --type merge -p '{"data":{"mapRoles":"- groups:\n  - system:bootstrappers\n  - system:nodes\n  rolearn: arn:aws:iam::405350004483:role/HRI-BIGEKS-TEST-rTestEksNodeInstanceRole-WhtCrrr7LYoG\n  username: system:node:{{EC2PrivateDNSName}}\n- groups:\n  - system:masters\n  rolearn: arn:aws:iam::405350004483:role/AWSReservedSSO_rEKSDeveloperPermissionSet_509fcc0afc7a86a3\n  username: eks-developer-role\n- groups:\n  - system:masters\n  rolearn: arn:aws:iam::405350004483:role/AWSReservedSSO_EKSLogsPermissionSet_641e07934445cd33\n  username: eks-logs-user"}}'
configmap/aws-auth patched
