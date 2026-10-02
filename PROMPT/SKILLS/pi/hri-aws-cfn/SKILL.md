---
name: hri-aws-cfn
description: Author AWS CloudFormation YAML templates in the HRI house style — commented deploy header with PICKPROFILE, p/r naming prefixes, exported outputs feeding a set_stack_outputs shell pipeline, Retain only on EBS volumes and S3 buckets, S3 hardening defaults. Use whenever asked to create, scaffold, review, or modify a CloudFormation template or stack YAML. Authoring only — never deploys.
---

# CloudFormation Template Author (HRI style)

Generate CloudFormation YAML matching the user's conventions. The user
post-processes by hand, so fidelity to style beats novelty.

**Scope: authoring only.** Never run `aws cloudformation deploy`,
`create-stack`, `update-stack`, `create-change-set`, or any mutating AWS
call. Running `cfn-lint <file>` on emitted templates is allowed and
encouraged when the binary exists; otherwise leave the reminder in the
header.

---

## Environment context

- Accounts: `net`, `dev`, `test`, `production`. Stacks span accounts.
- Primary region `us-east-1` for all accounts. Legacy `us-west-1` exists
  in production only (Jira/Confluence) — use only when the user says so.
- Toolchain the templates feed:
  1. `set_stack_outputs <stack-name> <region> <profile>` — reads
     `describe-stacks`, `export`s every `OutputKey=OutputValue` as a shell
     variable.
  2. `set_aws_envs` — calls `set_stack_outputs` for every known stack in
     order, building the full cross-stack environment.
  3. Deploy headers reference those variables in `--parameter-overrides`.

Consequences: output keys are global shell variable names (rule 3), and
cross-account values travel as parameters, never `Fn::ImportValue` (rule 6).

---

## Hard rules

### 1. Header block — commented deploy command at the very top

First lines of the file: commented `aws cloudformation deploy`, then
commented validation commands, then any post-deploy reminders. It stays in
the file so it is visible in the AWS console.

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
- `--template-file` takes a plain path. No `file://` (that prefix is
  only for `validate-template --template-body`).
- **`--parameter-overrides`.** Include only if parameters actually need
  overriding. No parameters, or all have suitable `Default:` → omit the
  line and its continuation backslash entirely.
- **Override values** are `pParam="${rUpstreamOutputKey}"` — shell
  variables named after upstream stacks' `OutputKey`s, sourced via
  `set_stack_outputs`.
- `--capabilities` — decide automatically:
  - no IAM resources → omit the line
  - IAM resources, no explicit names → `CAPABILITY_IAM`
  - any explicit `RoleName`, `UserName`, `GroupName`, `PolicyName`,
    `ManagedPolicyName`, `InstanceProfileName` → `CAPABILITY_NAMED_IAM`
- `--region` **and** `--profile` are always the last two flags, in that
  order, on one line. Profile is the literal `PICKPROFILE` (user
  search/replaces). Region defaults to `us-east-1`.

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
- Outputs `r<PascalCase>`, no `o` prefix; key mirrors the resource logical
  id it references, with an attribute suffix for `!GetAtt` outputs
  (`rEksBogusClusterArn`, `rExampleInstancePrivateIp`)
- Output keys become shell environment variables via `set_stack_outputs`,
  so they must be globally unique across every stack the user sources.
  Include the component name (`rEksBogusCluster`, not `rCluster`). Warn on
  anything collision-prone.
- Physical names (`BucketName`, `RoleName`, etc.) only when the user asks
  or the resource requires it; prefer CFN-generated names.

### 4. No `pEnvironment` parameter

Templates are environment-neutral; environment is chosen at deploy time
via `--profile`/`--region` in the header. Add one only if explicitly
requested.

### 5. Every output gets an `Export`

Plain value for the shell pipeline, `Export` for same-account
`Fn::ImportValue` consumers.

```yaml
Outputs:
  rEksBogusCluster:
    Value: !Ref rEksBogusCluster
    Export:
      Name: !Sub "${AWS::StackName}-rEksBogusCluster"
```

Output anything plausibly useful later: every resource `!Ref` plus commonly
consumed `!GetAtt` values (ARNs, endpoints, ids, SG ids, OIDC issuer URLs).
`Description:` on outputs is optional.

### 6. Cross-stack values: parameters in, exports out

- Consuming a value from another stack → define a `pParam` and show the
  `"${rUpstreamKey}"` expansion in the header. This is the only pattern
  that works across accounts.
- `Fn::ImportValue` is permitted only when producer and consumer are
  known to be in the same account+region **and** the user asks for it.
  Default to parameters.

### 7. Retain policies — only two resource types

`DeletionPolicy: Retain` **and** `UpdateReplacePolicy: Retain` on:

- `AWS::EC2::Volume` (standalone, attached via `AWS::EC2::VolumeAttachment`)
- `AWS::S3::Bucket`

Nothing else. Explicitly **not**: launch-template `BlockDeviceMappings`,
ASG-managed volumes, EKS node group root disks, RDS, DynamoDB, EFS, KMS,
Secrets Manager. Defaults there avoid orphan accumulation. When emitting
RDS/DynamoDB/EFS/KMS/Secrets Manager, mention in the response that the
user may want Retain manually if the data warrants it.

Corollary: data that must outlive an instance goes on a standalone
`AWS::EC2::Volume` + `VolumeAttachment`, not a `BlockDeviceMapping`.

### 8. S3 bucket defaults

Single source of truth for bucket defaults — SSE-S3, all four
public-access blocks, Intelligent-Tiering at day 0 (avoids relying on
storage-class-on-PUT), plus Retain per rule 7.

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

### 9. YAML formatting

- `AWSTemplateFormatVersion: "2010-09-09"` (quoted)
- always a one-line `Description:` (≤1024 chars)
- 2-space indent, no tabs
- short-form intrinsics `!Ref` `!GetAtt` `!Sub` `!Select` `!Join`;
  prefer `!Sub` over `!Join`; long-form `Fn::` only where nesting
  forces it
- quote strings that look numeric (`"1.35"`, `"-1"`), date-like,
  boolean-like (`"on"`, `"off"`, `"yes"`, `"no"`), or contain
  `:` `#` `{` `[` `*` `&` `!` or a leading `-`
- otherwise leave unquoted

### 10. Tags

Every taggable resource: `Name` (descriptive) and `ManagedBy: CloudFormation`.

---

## Soft rules

- `Mappings` only when referenced — never emit unused blocks.
- `Conditions` when behavior differs at deploy time.
- `Metadata: AWS::CloudFormation::Interface` only when parameters > 5.
- Parameters get a `Default:` where a sensible one exists; use typed
  parameters (`AWS::EC2::VPC::Id`, `AWS::SSM::Parameter::Value<...>`)
  over `String` when applicable.

---

## Pre-emission checklist

- [ ] Commented deploy command first, `--region`/`--profile PICKPROFILE` last
- [ ] `--template-file` plain path; `file://` only on `validate-template`
- [ ] `--parameter-overrides` present only if needed; values are `"${rKey}"`
- [ ] `--capabilities` chosen per rule 1 (or omitted)
- [ ] `cfn-lint` + `validate-template` lines in header
- [ ] Access-key reminder if `AWS::IAM::User` present
- [ ] `AWSTemplateFormatVersion: "2010-09-09"` quoted; `Description:` populated
- [ ] All params `p…`, all resources `r…`, all outputs `r…` with component name
- [ ] Every output has `Value` and `Export.Name: !Sub "${AWS::StackName}-<key>"`
- [ ] Cross-stack inputs are parameters, not `Fn::ImportValue`
- [ ] Retain on `AWS::EC2::Volume` and `AWS::S3::Bucket` only
- [ ] Every bucket has SSE-S3, public-access block, Intelligent-Tiering rule
- [ ] No `pEnvironment`
- [ ] `Name` + `ManagedBy: CloudFormation` on every taggable resource
- [ ] No unused `Mappings`; short-form intrinsics; 2-space indent
- [ ] Numeric/boolean-looking strings quoted

## Post-emission

Run `cfn-lint` if available and report results. Otherwise remind the user
to run the two validation commands from the header. If RDS/DynamoDB/EFS/
KMS/Secrets Manager were emitted, note the Retain decision (rule 7).

---

## Reference skeleton — EC2 with retained data volume

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
        - IpProtocol: "-1"
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

## Reference skeleton — S3 bucket with IAM user

Shows `CAPABILITY_NAMED_IAM`, no `--parameter-overrides`, and the
access-key reminder. (May be moved to `references/s3-iam-user.yaml`.)

```yaml
# Edit --profile (and --region if needed) for the target environment.
# aws cloudformation deploy \
#   --stack-name HRI-NETBACKUP-ALB-NB-2 \
#   --template-file HRI-NETBACKUP-ALB-NB-2.yaml \
#   --capabilities CAPABILITY_NAMED_IAM \
#   --region us-east-1 --profile PICKPROFILE
#
# Validate before deploy:
#   cfn-lint HRI-NETBACKUP-ALB-NB-2.yaml
#   aws cloudformation validate-template --template-body file://HRI-NETBACKUP-ALB-NB-2.yaml --region us-east-1 --profile PICKPROFILE
#
# After deploy, create access key for the IAM user:
#   aws iam create-access-key --user-name Netbackup-ALB-NB-2-User --profile PICKPROFILE
# (Access keys are intentionally NOT in the template — they would
#  land in stack outputs / describe-stacks history.)
AWSTemplateFormatVersion: "2010-09-09"
Description: Netbackup ALB backup bucket and IAM user
Resources:
  rNetbackupBucket:
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
  rNetbackupUser:
    Type: AWS::IAM::User
    Properties:
      UserName: Netbackup-ALB-NB-2-User
      Tags:
        - Key: Name
          Value: Netbackup-ALB-NB-2-User
        - Key: ManagedBy
          Value: CloudFormation
Outputs:
  rNetbackupBucket:
    Value: !Ref rNetbackupBucket
    Export:
      Name: !Sub "${AWS::StackName}-rNetbackupBucket"
  rNetbackupBucketArn:
    Value: !GetAtt rNetbackupBucket.Arn
    Export:
      Name: !Sub "${AWS::StackName}-rNetbackupBucketArn"
  rNetbackupUser:
    Value: !Ref rNetbackupUser
    Export:
      Name: !Sub "${AWS::StackName}-rNetbackupUser"
  rNetbackupUserArn:
    Value: !GetAtt rNetbackupUser.Arn
    Export:
      Name: !Sub "${AWS::StackName}-rNetbackupUserArn"
```

---

*Consolidated 2026-10-02 from three prior versions: `hri-aws-cfn` skill file (authoritative), "CloudFormation Template Author (HRI Style)" skill, and the April 2026 "HRI CloudFormation Template Conventions" note (superseded; contributed the set_stack_outputs pipeline, cross-account rule, and region notes).*
