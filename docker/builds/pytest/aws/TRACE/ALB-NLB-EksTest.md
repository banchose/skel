# AWS Alb/Nlb/Eks Troubleshooting

![e18308155325e3da16f46d068451cb44.png](:/6133b88ae08e46f5b93350a78b1fdfd9)

## Eks Test Network Troubleshooting (Scroll down)

Excellent! This is a **beautifully organized** automation approach for managing CloudFormation stack outputs across your entire AWS Organization. This gives me the complete picture of your environment now.

Let me update the troubleshooting reference with your **actual** environment variables:

---

## **Updated NLB Troubleshooting Guide - TEST Environment**

Using your exported variables from `set_aws_envs`:

### **Infrastructure Overview - TEST**

```bash
# Core Network
InspectVPC:     vpc-07717f856d9d4b115 (172.22.0.0/20)
ServiceVPC:     vpc-08b2d4bc8cbae9302 (172.22.32.0/20)
TestEksVPC:     vpc-07d51fd176cc6e6b3 (172.22.240.0/20)

Transit Gateway: tgw-0d31117302b381554
TGW Route Table: tgw-rtb-0d060fcaa8182de30

# Public ALB (InspectVPC)
ALB Name:       WildRide
ALB DNS:        WildRide-2000142468.us-east-1.elb.amazonaws.com
ALB Listener:   arn:aws:elasticloadbalancing:us-east-1:211262586138:listener/app/WildRide/7bcd7a64acaf4ae5/d5393370afeb5184

# EKS TEST Cluster
Cluster:        EksTest
Endpoint:       https://43003891DBB3CBD14160A984D6727493.gr7.us-east-1.eks.amazonaws.com
Node Group:     EksTest/rTestEksNodeGroup

# NLB (TestEksVPC)
NLB DNS:        TestEksNetworkLoadBalancer-315edbfaca198e6a.elb.us-east-1.amazonaws.com
NLB ARN:        arn:aws:elasticloadbalancing:us-east-1:405350004483:loadbalancer/net/TestEksNetworkLoadBalancer/315edbfaca198e6a
NLB SG:         sg-02994529d5b42d9ef
Target Group:   TestEksPrivateNginxIngress (99844385460d0358)
NodePort:       30080
```

---

## **Quick Troubleshooting Commands**

```bash
# After running: source set_aws_envs

# 1. Get current NLB IPs
echo "Resolving: $rTestEksNetworkLoadBalancerDNS"
dig +short $rTestEksNetworkLoadBalancerDNS

# 2. Check NLB Security Group rules
aws ec2 describe-security-groups \
  --group-ids $rTestEksNetworkLoadBalancerSecurityGroup \
  --profile test \
  --query 'SecurityGroups[0].IpPermissions' \
  --output table

# 3. Get ALB subnet CIDRs (source IPs that will hit NLB)
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$rInspectVpc" "Name=tag:Name,Values=*Public*" \
  --profile net \
  --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone]' \
  --output table

# 4. Check NLB target health
aws elbv2 describe-target-health \
  --target-group-arn $rTestEksPrivateNginxIngress \
  --profile test \
  --output table

# 5. Check ALB target group pointing to NLB
aws elbv2 describe-target-groups \
  --load-balancer-arn $rPubAppLoadBalancer \
  --profile net \
  --query 'TargetGroups[?contains(TargetGroupName, `Test`)]' \
  --output table
```

---

## **Common Issue: ALB → NLB Security Group**

The **most common problem** is the NLB security group not allowing traffic from the ALB's subnets:

```bash
# Check what the NLB SG currently allows
aws ec2 describe-security-groups \
  --group-ids $rTestEksNetworkLoadBalancerSecurityGroup \
  --profile test \
  --query 'SecurityGroups[0].IpPermissions[*].[IpProtocol,FromPort,ToPort,IpRanges[*].CidrIp]' \
  --output table

# It should show:
# tcp | 80 | 80 | 172.22.0.0/24  (InspectPublicSubnet)
# tcp | 80 | 80 | 172.22.1.0/24  (InspectPublicSubnetAZB)
```

**To fix if missing:**

```bash
# Get the public subnet CIDRs from InspectVPC
aws ec2 describe-subnets \
  --subnet-ids $rInspectPublicSubnet $rInspectPublicSubnetAZB \
  --profile net \
  --query 'Subnets[*].CidrBlock' \
  --output text

# Add rules (example - adjust CIDRs from above)
aws ec2 authorize-security-group-ingress \
  --group-id $rTestEksNetworkLoadBalancerSecurityGroup \
  --ip-permissions \
    IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges='[{CidrIp=172.22.0.0/24},{CidrIp=172.22.1.0/24}]' \
  --profile test \
  --region us-east-1
```

---

## **Packet Capture Workflow**

When you need to capture traffic:

```bash
# 1. Get current NLB IPs
NLB_IPS=$(dig +short $rTestEksNetworkLoadBalancerDNS)
echo "NLB IPs: $NLB_IPS"

# 2. Get node IPs from target group
NODE_IPS=$(aws elbv2 describe-target-health \
  --target-group-arn $rTestEksPrivateNginxIngress \
  --profile test \
  --query 'TargetHealthDescriptions[*].Target.Id' \
  --output text)

echo "Nodes in target group: $NODE_IPS"

# 3. SSM to a node
FIRST_NODE=$(echo $NODE_IPS | awk '{print $1}')
aws ssm start-session \
  --target $FIRST_NODE \
  --profile test \
  --region us-east-1

# 4. On the node:
sudo tcpdump -i any -n port 30080 -vv
# Look for source IPs from: 172.22.0.0/24 or 172.22.1.0/24
```

---

## **DNS Resolution Path**

```
*.healthresearch.org (public DNS)
    ↓
WildRide-2000142468.us-east-1.elb.amazonaws.com
    ↓
ALB IPs: 172.22.0.x, 172.22.1.x (InspectVPC public subnets)
    ↓
TestEksNetworkLoadBalancer-315edbfaca198e6a.elb.us-east-1.amazonaws.com
    ↓
NLB IPs: 172.22.240.x, 172.22.241.x (TestEksVPC private subnets)
    ↓
EC2 Nodes NodePort 30080
    ↓
ingress-nginx pod
    ↓
Application service
```

---

## **Environment Comparison**

You have a consistent pattern across environments:

| Env | EKS Cluster | VPC | NLB DNS | NLB SG | NodePort |
|-----|-------------|-----|---------|---------|----------|
| TEST | EksTest | vpc-07d51fd176cc6e6b3 | TestEksNetworkLoadBalancer-... | sg-02994529d5b42d9ef | 30080 |
| QA | EksQa | vpc-0e62abadedf70bd81 | QaEksNetworkLoadBalancer-... | sg-0293d5ba23327a08e | 30080 |
| PROD | [expired token] | [expired token] | [expired token] | [expired token] | 30080 |

---

**Question:** Do you want me to create a single troubleshooting script that uses these environment variables? Something like:

```bash
#!/usr/bin/env bash
# ~/gitdir/aws/TROUBLESHOOTING/check-nlb-path.sh

source ~/gitdir/aws/set_aws_envs

ENVIRONMENT="${1:-test}"  # test, qa, or prod

case $ENVIRONMENT in
  test)
    NLB_DNS=$rTestEksNetworkLoadBalancerDNS
    NLB_SG=$rTestEksNetworkLoadBalancerSecurityGroup
    TG_ARN=$rTestEksPrivateNginxIngress
    PROFILE="test"
    ;;
  qa)
    NLB_DNS=$rQaEksNetworkLoadBalancerDNS
    NLB_SG=$rQaEksNetworkLoadBalancerSecurityGroup
    TG_ARN=$rQaEksNlbTargetGroup
    PROFILE="test"
    ;;
  *)
    echo "Usage: $0 {test|qa|prod}"
    exit 1
    ;;
esac

# ... run checks
```

I completely understand your frustration! The NLB is deceptively simple but has several "hidden" layers that make troubleshooting a pain. Let me create a text-based diagram that captures all those details you need when troubleshooting:

```
INTERNET → ALB (*.healthresearch.org) 
           Public Subnet IPs: [Need to document these]
		   |  wildride-2000142468.us-east-1.elb.amazonaws.com
           │  InspectVPC:     vpc-07717f856d9d4b115 (172.22.0.0/20)
		   |
		   |
           │ Source IPs = ALB Subnet CIDR blocks
           │ (These become the "client" IPs hitting NLB: 172.22.0.0/20)
           ↓
       ┌─────────────────────────────────────────────────────┐
       │  NLB: TestEksNetworkLoadBalancer-315edbfaca198e6a...│
       │  DNS: ...elb.us-east-1.amazonaws.com                │
       │                                                     │
       │  Resolved IPs (via nslookup):                       │
       │    • NLB-IP1: [Elastic Network Interface IP]        │
       │    • NLB-IP2: [Elastic Network Interface IP]        │
       │    • (One per AZ/subnet)                            │
       │                                                     │
       │  VPC: vpc-07d51f8176cce6b3                          │
       │  Subnets: Private EKS subnets                       │
       │                                                     │
       │  Security Group: sg-02994529d5b42d9ef               │
       │  ├─ Inbound Rule:                                   │
       │  │  Source: ALB Subnet CIDRs (10.x.x.x/24, etc.)    │
       │  │  Port: 80                                        │
       │  │  Protocol: TCP                                   │
       │  └─ (Must match ALB subnet ranges!)                 │
       │                                                     │
       │  Listener: Port 80 (TCP)                            │
       │     └─→ Target Group                                │
       └──────────────────┬──────────────────────────────────┘
                          │
                          ↓
              ┌────────────────────────┐
              │   Target Group         │
              │   Port: 30080          │
              │   Protocol: TCP        │
              │   Type: instance       │
              │                        │
              │   Targets:             │
              │   • i-022fbc01051c8942d (node 1) subnet1 port:30080
              │   • i-040b407306aca4728 (node 2) subnet2 port:30080
              │   (EC2 worker nodes)   │
              └───────────┬────────────┘
                          │
                          ↓
              ┌────────────────────────┐
              │  Ingress NGINX         │
              │  (DaemonSet/Service)   │
              │  NodePort: 30080       │
              │                        │
              │  Pod IPs on nodes      │
              └───────────┬────────────┘
                          │
                          ↓
              ┌───────────────────────┐
              │  App Service          │
              │  (Pisal/Pisalapi)     │
              └───────────────────────┘
```

## **Troubleshooting Checklist - The NLB "Gotchas"**

### 1. **Finding the Actual NLB IPs**
```bash
# AWS doesn't show these in console easily
nslookup TestEksNetworkLoadBalancer-315edbfaca198e6a.elb.us-east-1.amazonaws.com

# Or use dig for cleaner output
dig +short TestEksNetworkLoadBalancer-315edbfaca198e6a.elb.us-east-1.amazonaws.com
```

### 2. **Security Group Source Mystery**
The NLB security group must allow:
- **Source**: ALB's **subnet CIDR blocks** (NOT ALB's security group!)
- **Port**: 80 (or whatever your listener port is)
- Traffic appears to come FROM the ALB subnets, not the ALB IPs themselves

### 3. **Target Group Configuration**
[Inference] Based on your note about NodePort 30080:
```
Type: instance (not IP)
Protocol: TCP
Port: 30080 (NodePort where ingress-nginx listens)
Health Check: TCP:30080 or HTTP:30080/healthz
Targets: EC2 instance IDs of EKS worker nodes
```

### 4. **Packet Capture Pain Points**
When doing tcpdump on nodes:
- Look for source IPs from **ALB subnet ranges**, not internet IPs
- Traffic hits **NodePort 30080** on the node's primary ENI
- [Inference] ingress-nginx then routes internally to pod IPs

### 5. **The DNS → IP Resolution Problem**
- NLB DNS name resolves to ENI IPs in each AZ
- These IPs can change if you modify subnets/AZs
- ALB target group should use NLB's **DNS name**, not IPs
- But for packet captures, you need to know current IPs

---

## **Quick Reference Card**

| What | Where to Find It |
|------|-----------------|
| NLB Security Group | `sg-02994529d5b42d9ef` [6] |
| NLB Current IPs | `nslookup <nlb-dns-name>` |
| Target Group Port | 30080 [6] |
| Ingress NGINX NodePort | 30080 [6] |
| ALB Source IPs | Check ALB subnet CIDRs in VPC |
| Node Instance IDs | `i-022fbc01051c8942d`, `i-040b407306aca4728` [From your diagram] |

---

## **Common Failure Scenarios**

1. **ALB can't reach NLB**
   - Check: NLB SG allows ALB subnet CIDRs on port 80

2. **NLB shows unhealthy targets**
   - Check: Nodes allow traffic on port 30080 from NLB subnets
   - Check: ingress-nginx is running and listening on 30080
   - Check: Node security group [Inference from requirement to add NLB SG] [6]

3. **Wrong IPs in packet capture**
   - Did you resolve NLB DNS recently? IPs may have changed
   - Are you capturing on the right node? (Target group has 2 nodes)

---

Would it help if I created a more detailed diagram showing the security group rules and exact CIDR flows? Or a script to quickly gather all these details from your environment?
