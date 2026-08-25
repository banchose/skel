---
name: hri-aws-cfn
description: Author AWS CloudFormation YAML templates in the user's HRI house style — commented deploy header with PICKPROFILE, p/r naming prefixes, exported outputs, Retain policies, S3 defaults. Use whenever asked to create, scaffold, review, or modify a CloudFormation template or stack YAML. Template authoring only — never deploys.
---

# CloudFormation Template Author (HRI style)

Generate CloudFormation YAML matching the user's conventions. The user
post-processes by hand, so fidelity to style beats novelty.

**Scope: authoring only.** Never run `aws cloudformation deploy`,
`create-stack`, `update-stack`, or any mutating AWS call. Running
`cfn-lint <file>` on emitted templates is allowed and encouraged when the
binary exists; otherwise just leave the reminder in the header.

---

## Hard rules

### 1. Header block — commented deploy command at the very top

First lines of the file are a commented `aws cloudformation deploy`
invocation, then commented validation commands, then any post-deploy
reminders. It stays in the file so it is visible in the AWS console.

```yaml
# Edit --profile (and --region if needed) for the target environment.
# aws cloudformation deploy \
#   --stack-name <STACK-NAME> \
#   --template-file <STACK-NAME>.yaml \
#   --capabilities CAPABILITY_IAM \
#   --parameter-overrides \
#     pParamOne="${rUpstreamOutputOne}" \
#     pParamTwo="${rUpstreamOutputTwo}" \
#   --region us-east-1 --profile PICKPROFILE
#
# Validate before deploy:
#   cfn-lint <STACK-NAME>.yaml
#   aws cloudformation validate-template --template-body file://<STACK-NAME>.yaml --region us-east-1 --profile PICKPROFILE
```

- **Naming.** Base is `HRI-<COMPONENT>`; file name matches stack name.
  Environment suffix (`-QA`, `-TEST`, `-PROD`) is optional and
  user-chosen — never invent one. Unclear? Propose and ask.
- **`--parameter-overrides`.** Include only if parameters actually need
  overriding. No parameters, or all have suitable `Default:` → omit the
  line and its continuation backslash entirely.
- **Override values** reference shell variables named after upstream
  stacks' exported `OutputKey`s (user sources them via a
  `set_stack_outputs` bash function).
- **`--capabilities`** — decide automatically:
  - no IAM resources → omit the line
  - IAM resources, no explicit names → `CAPABILITY_IAM`
  - any explicit `RoleName`/`UserName`/`GroupName`/`PolicyName`/`ManagedPolicyName` → `CAPABILITY_NAMED_IAM`
- **Profile** is the literal `PICKPROFILE`. **Region** defaults to `us-east-1`.

### 2. IAM user → access-key reminder

When the template contains `AWS::IAM::User`, append to the header:

```yaml
# After deploy, create access key for the IAM user:
#   aws iam create-access-key --user-name <UserName> --profile PICKPROFILE
# (Access keys are intentionally NOT in the template — they would
#  land in stack outputs / describe-stacks history.)
```

### 3. Naming prefixes

- Parameters `p<PascalCase>` — `pVpcId`, `pEksClusterName`
- Resources `r<PascalCase>` — `rEksCluster`
- Outputs `r<PascalCase>`, no `o` prefix; key mirrors the resource logical id
- Output keys become shell environment variables, so they must be globally
  unique across every stack the user sources. Include the component name
  (`rEksBogusCluster`, not `rCluster`). Warn on anything collision-prone.

### 4. No `pEnvironment` parameter

Templates are environment-neutral; environment is chosen at deploy time via
`--profile`/`--region` in the header. Add one only if explicitly requested.

### 5. Every output gets an `Export`

Plain value for the bash script, `Export` for future `Fn::ImportValue`.

```yaml
Outputs:
  rEksBogusCluster:
    Value: !Ref rEksBogusCluster
    Export:
      Name: !Sub "${AWS::StackName}-rEksBogusCluster"
```

Output anything plausibly useful later: every resource `!Ref` plus commonly
consumed `!GetAtt` values (ARNs, endpoints, ids, SG ids, OIDC issuer URLs).

### 6. Retain policies — only two resource types

`DeletionPolicy: Retain` **and** `UpdateReplacePolicy: Retain` on:

- `AWS::EC2::Volume` (standalone, attached via `AWS::EC2::VolumeAttachment`)
- `AWS::S3::Bucket`

Nothing else. Explicitly **not**: launch-template `BlockDeviceMappings`,
ASG-managed volumes, EKS node group root disks, RDS, DynamoDB, EFS, KMS,
Secrets Manager. Defaults there avoid orphan accumulation. When emitting
RDS/DynamoDB/EFS/KMS/Secrets Manager, mention in the response that the user
may want Retain manually if the data warrants it.

### 7. S3 bucket defaults

This block is the single source of truth for bucket defaults — SSE-S3,
all four public-access blocks, Intelligent-Tiering at day 0 (avoids relying
on storage-class-on-PUT), plus Retain per rule 6.

```yaml
rBucket:
  Type: AWS::S3::Bucket
  DeletionPolicy: Retain
  UpdateReplacePolicy: Retain
  Properties:
    BucketEncryption:
      ServerSideEncryptionConfiguration:
        - ServerSideEncryptionByDefault:
            SSEAlgorithm: AES256
    PublicAccessBlockConfiguration:
      BlockPublicAcls: true
      BlockPublicPolicy: true
      IgnorePublicAcls: true
      RestrictPublicBuckets: true
    LifecycleConfiguration:
      Rules:
        - Id: TransitionToIntelligentTiering
          Status: Enabled
          Transitions:
            - StorageClass: INTELLIGENT_TIERING
              TransitionInDays: 0
    Tags:
      - Key: Name
        Value: !Sub "${AWS::StackName}-bucket"
      - Key: ManagedBy
        Value: CloudFormation
```

Off by default, add only on request: versioning, server access logging,
event notifications, replication.

### 8. YAML formatting

- `AWSTemplateFormatVersion: "2010-09-09"` (quoted)
- always a one-line `Description:` (≤1024 chars)
- 2-space indent, no tabs
- short-form intrinsics `!Ref !GetAtt !Sub !Select !Join`; prefer `!Sub`
- quote strings that look numeric (`"1.35"`), date-like, boolean-like
  (`"on"`, `"off"`, `"yes"`, `"no"`), or contain `:`&nbsp;`#`&nbsp;`{`&nbsp;`[`&nbsp;`*`&nbsp;`&`&nbsp;`!` or a leading `-`
- otherwise leave unquoted

### 9. Tags

Every taggable resource: `Name` (descriptive) and `ManagedBy: CloudFormation`.

---

## Soft rules

- `Mappings` only when referenced — never emit unused blocks.
- `Conditions` when behavior differs at deploy time.
- `Metadata: AWS::CloudFormation::Interface` only when parameters > 5.

---

## Easy to forget

- `--capabilities` line chosen (or deliberately omitted) per rule 1
- `--parameter-overrides` dropped when nothing needs overriding
- access-key reminder present whenever `AWS::IAM::User` exists
- output keys carry the component name (they are global shell vars)
- Retain on standalone EBS volumes and buckets, nowhere else
- no `pEnvironment`

---

## Reference skeletons

`references/s3-iam-user.yaml` — bucket + IAM user, showing
`CAPABILITY_NAMED_IAM` and the access-key reminder. Read it when the request
involves S3 or IAM users.

Inline: EC2 with a retained data volume.

```yaml
# Edit --profile (and --region if needed) for the target environment.
# aws cloudformation deploy \
#   --stack-name HRI-EXAMPLE \
#   --template-file HRI-EXAMPLE.yaml \
#   --parameter-overrides \
#     pVpcId="${rQaEksVpc}" \
#     pSubnetId="${rQaEksWorkloadPrivateSubnet}" \
#   --region us-east-1 --profile PICKPROFILE
#
# Validate before deploy:
#   cfn-lint HRI-EXAMPLE.yaml
#   aws cloudformation validate-template --template-body file://HRI-EXAMPLE.yaml --region us-east-1 --profile PICKPROFILE
AWSTemplateFormatVersion: "2010-09-09"
Description: Example stack with EC2 instance and retained data volume

Parameters:
  pVpcId:
    Type: AWS::EC2::VPC::Id
  pSubnetId:
    Type: AWS::EC2::Subnet::Id
  pInstanceType:
    Type: String
    Default: t3.medium

Resources:
  rExampleSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Example SG
      VpcId: !Ref pVpcId
      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0
          Description: Allow all outbound
      Tags:
        - Key: Name
          Value: !Sub "${AWS::StackName}-sg"
        - Key: ManagedBy
          Value: CloudFormation

  rExampleInstance:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref pInstanceType
      SubnetId: !Ref pSubnetId
      SecurityGroupIds:
        - !Ref rExampleSecurityGroup
      Tags:
        - Key: Name
          Value: !Sub "${AWS::StackName}-ec2"
        - Key: ManagedBy
          Value: CloudFormation

  rExampleDataVolume:
    Type: AWS::EC2::Volume
    DeletionPolicy: Retain
    UpdateReplacePolicy: Retain
    Properties:
      Size: 100
      VolumeType: gp3
      AvailabilityZone: !GetAtt rExampleInstance.AvailabilityZone
      Tags:
        - Key: Name
          Value: !Sub "${AWS::StackName}-data"
        - Key: ManagedBy
          Value: CloudFormation

  rExampleVolumeAttachment:
    Type: AWS::EC2::VolumeAttachment
    Properties:
      Device: /dev/sdf
      InstanceId: !Ref rExampleInstance
      VolumeId: !Ref rExampleDataVolume

Outputs:
  rExampleSecurityGroup:
    Value: !Ref rExampleSecurityGroup
    Export:
      Name: !Sub "${AWS::StackName}-rExampleSecurityGroup"
  rExampleInstance:
    Value: !Ref rExampleInstance
    Export:
      Name: !Sub "${AWS::StackName}-rExampleInstance"
  rExampleInstancePrivateIp:
    Value: !GetAtt rExampleInstance.PrivateIp
    Export:
      Name: !Sub "${AWS::StackName}-rExampleInstancePrivateIp"
  rExampleDataVolume:
    Value: !Ref rExampleDataVolume
    Export:
      Name: !Sub "${AWS::StackName}-rExampleDataVolume"
```
