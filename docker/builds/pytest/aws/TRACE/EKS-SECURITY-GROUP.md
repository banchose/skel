# EKS Security Group (Nodes Security group including control plane)

## Inbound

- The ingress port (30080)
- The NLB IP addresses as only source
- NLB maitains a state table for return traffic
- Packets are forwarded back to the NLB -> ALB (via state tables)

EKS Interface
Source IP Behavior: Since you're using TargetType: instance, the Nginx pods will see the NLB's IP as the source (from your transit private subnets)

## ALB -> NLB (Packet entering the NLB)

The NLB maitains state tables and packets are routed in the reverse path to the alb
Eks sends the packets back to the NLB. That is why you only need to let in the NLB endpoints (the NLB security group) and the port the nginx ingress is listening on (30080)

- Source IP: ALB_IP (from ALB subnets)
- Destination IP: NLB_IP (the NLB listener address)

Source IP: NLB_IP (NLB performs source NAT)
Destination IP: EKS_Node_IP (NLB performs destination NAT)
