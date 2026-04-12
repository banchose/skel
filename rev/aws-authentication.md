# AWS Authenticaton
## Account
  A container for 'identities' and 'resources'
  Unique email address and a credit card (or another AWS acceptable payment method)
  First account root user (no restrictions)
  Add additional users non-root users using in IAM (root is not there)
    IAM service to create other identities (identity starts no perms)

## Authentication SSO awscliv2
  You authenticate to IAM Identity Center 
  -> SSO access token (from Identity Center token) cached
  That is the token that assumes the roles in other accounts
  aws sso login --sso-session hri (authenticates and caches the SSO access token)
  aws s3 ls --profile test (SDK uses the cached token to assume the role in that account)

## IAM ##
  IAM is a global service (no charge)
    User
    Group (collection of users)
    Role (uncertain number of entities)
    IAM Policy
      Used to allow access to AWS services
      ONLY when attached to users,groups,roles)

## IAM Groups
  Can attach a identity-policy to a group
  Cannot identify a group as a principal in a policy
  Not a principal or authenticated entity
  Permissions only, principals are authenticated IAM entities

#### aws cli #####################
  IAM Acess Keys
    0 or 1 or 2
    2 parts
      Access Key ID
      Secret Access Key
    created, deleted, inactive, active
    Long term credentials
    aws configure
      You need Access Key ID
      You need Secret Key (shown once)
  Rotation
    While existing key active (1 key)
    make new one (2 keys now)
    change cli utilies to use new one
    delete the old one (1 key now)
  Roles do NOT use IAM Access Keys
#### Organization
  Consolitate billing and ids, reservations, and volume discounts, SCPs
  Take a standard AWS account
  You **use this standard account** to create the Organization
    As non-root admin/root (not rec)
    Makes this account the "Management Account"
  Invite other accounts to **approve** the invites to join the Organization
  When standard AWS accounts join an Organization, they are now "Member Accounts"
  Passes billing information is passed to the Organization and allows Consolitate billing
  Organizational Root container (contains management, memeber, OUs other containers)
  Adding an account only needs an email
  Instead of users in each account, roles are used in their place in each account
#### IAM Identity Center
  Assigning a user to an AWS account in Identity Center
    Creates roles in each account (max 1000 roles per accnt)
    Attaches the poicies specified in the permissionset to those roles
  Can use identity fedration for on-premises identities
  AWS access portal: https://d-9067806dc9.awsapps.com/start
##
aws sts get-caller-identity
  Proof of identity -> Issue temp credentials
    access key, secret key, session token
  IAM user/service calls 'sts:AssumeRole, sts checks the roles trust polcy
  If allowed by trust policy, sts mints temporary credentials
aws sso login - IAM identity Center
  Identity Center determines which accounts/PermissionSets your entitled to
  When accessing an account, Identity Center calls STS assumeRole (role must be in account)
  **The assumed role must exist in the account (via permissionsets/account association)
You → Identity Center (authenticate) → STS AssumeRole → temporary creds → ~/.aws/cli/cache
#########################
aws sso login --sso-session hri --no-browser --use-device-code
~/.aws/config example
------
[sso-session hri]
sso_start_url = https://d-9067806dc9.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access

[profile net]
sso_session = hri
sso_account_id = 211262586138
sso_role_name = AWSAdministratorAccess
region = us-east-1
------
########### EKS
Context = profile = assumed role
kubernetes context -> kubernetes user -> aws profile
Role, context, permissionset, profile
The kubenetes context maps a user with a cluster
  The kubernetes 'user' points to both a AWS **cluster** name and a AWS **profile** (aws sso login --profile xyz)
  PermissionSets map a group or user to an account with a trust policy with whom can assume it
  AWS PermissionSets create roles in each of the accounts that 'xyz' can assume
aws eks update-kubeconfig --region region-code --name my-cluster
##### Eks Control Plane
  When you create a new cluster, Amazon EKS creates an endpoint
  Endpoint used by kubectl
  Default Public enabled/Private disabled (no vpc or subnet needed)
  If public, publishes a resolveable url, if private the same but resolves to private IPS
  Can be both private and public.  Vpc needed for private. no public subnet, aws just publishes it
  Eks Nodes connect to the cluster control plane over Kubernetes API server endpoints
### kubectl
  Uses 'exec' aws in ~/.kube/config to call aws and cluster has cluster endpoint https://CC7A64222E08AEF734022C4F2123C68E.gr7.us-east-1.eks.amazonaws.com
### Oddball
  aws cloudformation get-template --stack-name <stack-name> --query 'TemplateBody' --region us-east-1 --profile test
