aws eks update-cluster-config --region us-east-1 --name rEksCluster --logging '{"clusterLogging":[{"types":["authenticator","audit"],"enabled":true}]}' --profile test
