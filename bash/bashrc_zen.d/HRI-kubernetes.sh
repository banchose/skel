hri-cluster-checks() {

  echo "### ON PREM ###"
  kubectl get pods --context Prod-Admin@Prod
  kubectl get pods --context QA-Admin@QA
  kubectl get pods --context Test-Admin@Test
  kubectl get pods --context DMZ-Admin@DMZ

  echo "### AWS ###"
  kubectl get pods --context arn:aws:eks:us-east-1:315633532929:cluster/EksProd
  kubectl get pods --context arn:aws:eks:us-east-1:405350004483:cluster/EksQa
  kubectl get pods --context arn:aws:eks:us-east-1:405350004483:cluster/EksTest

}
