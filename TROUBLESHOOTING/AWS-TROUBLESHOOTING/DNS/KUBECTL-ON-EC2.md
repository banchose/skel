# kubectl on ec2

```sh
# Instance from net Service Ec2
export in=i-04aebda9960485984
aws ssm start-session --target "${in}"  --profile net
source ~/gitdir/skel/.bashrc

 aws eks list-clusters --profile test
 aws eks update-kubeconfig --name rEksCluster --profile test
```
