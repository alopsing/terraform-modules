# AWS IAM Module

Terraform module to create IAM roles, policies, instance profiles, and OIDC providers.

## Features

- IAM roles with configurable assume role policies
- Managed and inline policy attachments
- Instance profiles for EC2
- Standalone IAM policies
- OIDC providers for federated access (e.g., EKS IRSA)
- Consistent resource tagging

## Usage

### Basic

```hcl
module "iam" {
  source = "../../modules/security/iam"

  name        = "my-app"
  environment = "dev"

  roles = {
    app = {
      description = "Application EC2 role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action    = "sts:AssumeRole"
          Effect    = "Allow"
          Principal = { Service = "ec2.amazonaws.com" }
        }]
      })
      create_instance_profile = true
    }
  }
}
```

## Examples

- [Basic](examples/basic/) — Single role with instance profile
- [Complete](examples/complete/) — Multiple roles, inline policies, standalone policies

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for IAM resources | `string` | n/a | yes |
| environment | Environment name (dev, staging, prod) | `string` | n/a | yes |
| roles | Map of IAM roles to create | `map(object)` | `{}` | no |
| policies | Map of IAM policies to create | `map(object)` | `{}` | no |
| oidc\_providers | Map of OIDC providers to create | `map(object)` | `{}` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| role\_arns | Map of role names to ARNs |
| role\_names | Map of role keys to names |
| instance\_profile\_arns | Map of instance profile names to ARNs |
| instance\_profile\_names | Map of instance profile keys to names |
| policy\_arns | Map of policy names to ARNs |
| oidc\_provider\_arns | Map of OIDC provider names to ARNs |
<!-- END_TF_DOCS -->
