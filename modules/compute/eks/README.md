# EKS Module

Terraform module for creating an Amazon EKS cluster with managed node groups, cluster add-ons, OIDC provider for IRSA, and CloudWatch logging.

## Usage

```hcl
module "eks" {
  source = "path/to/modules/compute/eks"

  name         = "my-platform"
  environment  = "dev"
  cluster_name = "my-dev-cluster"
  subnet_ids   = ["subnet-111", "subnet-222", "subnet-333"]
  vpc_id       = "vpc-12345678"

  node_groups = {
    general = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      min_size       = 1
      max_size       = 4
    }
  }

  tags = {
    Project = "example"
  }
}
```

## Features

- EKS cluster with configurable Kubernetes version
- Managed node groups with auto-scaling configuration
- Cluster add-ons (CoreDNS, kube-proxy, vpc-cni) with optional version pinning
- OIDC provider for IAM Roles for Service Accounts (IRSA)
- CloudWatch logging with configurable log types
- Configurable public and private API endpoint access
- Dedicated IAM roles for cluster and node groups

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name prefix for resources | `string` | n/a | yes |
| environment | Environment (dev, staging, prod) | `string` | n/a | yes |
| cluster_name | Name of the EKS cluster | `string` | n/a | yes |
| subnet_ids | Subnet IDs for cluster and node groups | `list(string)` | n/a | yes |
| vpc_id | VPC ID | `string` | n/a | yes |
| tags | Additional tags | `map(string)` | `{}` | no |
| cluster_version | Kubernetes version | `string` | `"1.29"` | no |
| node_groups | Map of node group configurations | `map(object)` | `{}` | no |
| cluster_addons | Map of add-on configurations | `map(object)` | vpc-cni, coredns, kube-proxy | no |
| enable_cluster_logging | Enable CloudWatch logging | `bool` | `true` | no |
| cluster_log_types | Log types to enable | `list(string)` | `["api", "audit", "authenticator"]` | no |
| endpoint_private_access | Enable private API endpoint | `bool` | `true` | no |
| endpoint_public_access | Enable public API endpoint | `bool` | `true` | no |
| public_access_cidrs | CIDRs for public API access | `list(string)` | `["0.0.0.0/0"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the EKS cluster |
| cluster_arn | The ARN of the EKS cluster |
| cluster_endpoint | The endpoint for the EKS cluster API server |
| cluster_certificate_authority | Base64 encoded certificate data |
| oidc_provider_arn | The ARN of the OIDC provider |
| oidc_provider_url | The URL of the OIDC provider |
| node_group_arns | Map of node group ARNs |

## Examples

- [Basic](examples/basic/) - Single node group with default settings
- [Complete](examples/complete/) - Multiple node groups, logging, and custom access configuration
