# Terraform AWS Modules

[![Terraform CI](https://github.com/alopsing/terraform-modules/actions/workflows/ci.yml/badge.svg)](https://github.com/alopsing/terraform-modules/actions/workflows/ci.yml)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.6-623CE4?logo=terraform)](https://www.terraform.io/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

A production-quality collection of reusable Terraform modules for AWS infrastructure, featuring consistent patterns, comprehensive testing, security scanning, and composed architecture examples.

## Module Index

| Category | Module | Description |
|----------|--------|-------------|
| **Networking** | [VPC](modules/networking/vpc/) | Multi-AZ VPC with public/private subnets, NAT gateways, flow logs |
| **Compute** | [EC2](modules/compute/ec2/) | EC2 instances with AMI lookup, EBS volumes, security groups |
| | [EKS](modules/compute/eks/) | EKS cluster with managed node groups, OIDC, cluster add-ons |
| | [Lambda](modules/compute/lambda/) | Lambda functions with IAM roles, VPC config, event source mappings |
| **Storage** | [S3](modules/storage/s3/) | S3 buckets with versioning, encryption, lifecycle rules, public access block |
| | [DynamoDB](modules/storage/dynamodb/) | DynamoDB tables with GSI/LSI, autoscaling, encryption, PITR |
| | [RDS](modules/storage/rds/) | RDS instances with multi-AZ, automated backups, enhanced monitoring |
| **Security** | [IAM](modules/security/iam/) | IAM roles, policies, instance profiles, OIDC providers |
| **Messaging** | [SNS](modules/messaging/sns/) | SNS topics with subscriptions, encryption, FIFO support |
| | [SQS](modules/messaging/sqs/) | SQS queues (standard/FIFO) with DLQ, encryption, redrive policies |
| **CDN** | [CloudFront](modules/cdn/cloudfront/) | CloudFront distributions with S3/ALB origins, OAC, WAF integration |
| | [API Gateway](modules/cdn/api-gateway/) | REST API with authorizers, API keys, usage plans, CORS |

## Quick Start

```hcl
module "vpc" {
  source = "github.com/saikumarpola/terraform-modules//modules/networking/vpc"

  name        = "my-app"
  environment = "dev"
  cidr_block  = "10.0.0.0/16"

  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}
```

## Composed Architecture Examples

| Example | Modules Used | Description |
|---------|-------------|-------------|
| [Three-Tier Web App](examples/three-tier-webapp/) | VPC, EC2, RDS, S3, CloudFront | Classic web application architecture |
| [Serverless API](examples/serverless-api/) | API Gateway, Lambda, DynamoDB, S3, IAM | Serverless REST API |
| [EKS Microservices](examples/eks-microservices/) | VPC, EKS, IAM | Kubernetes platform with IRSA |

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.6.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [TFLint](https://github.com/terraform-linters/tflint) (optional, for linting)
- [Trivy](https://github.com/aquasecurity/trivy) (optional, for security scanning)

## Quality Tooling

| Tool | Purpose | Config |
|------|---------|--------|
| `terraform fmt` | Code formatting | Built-in |
| `terraform validate` | Configuration validation | Built-in |
| `terraform test` | Plan-level unit testing | `tests/unit/<module>_unit.tftest.hcl` per module |
| [TFLint](https://github.com/terraform-linters/tflint) | Linting & best practices | `.tflint.hcl` |
| [Trivy](https://github.com/aquasecurity/trivy) | Security scanning | Built-in rules |
| [terraform-docs](https://github.com/terraform-docs/terraform-docs) | Documentation generation | `.terraform-docs.yml` |
| [pre-commit](https://pre-commit.com/) | Git hooks | `.pre-commit-config.yaml` |

### Running Quality Checks

```bash
# Format all files
terraform fmt -recursive

# Validate a module
cd modules/networking/vpc
terraform init -backend=false
terraform validate

# Run unit tests for a module
cd modules/networking/vpc
terraform init -backend=false
terraform test -test-directory=tests/unit

# Lint all modules
for dir in modules/*/*; do
  tflint --config "$(pwd)/.tflint.hcl" --chdir "$dir"
done

# Security scan
trivy config modules/
```

## Module Design Conventions

Every module follows the same structure:

```
modules/<category>/<module>/
  ├── main.tf           # Primary resources
  ├── variables.tf      # Input variables with validation
  ├── outputs.tf        # Output values
  ├── versions.tf       # Provider and Terraform version constraints
  ├── locals.tf         # Local values and common tags
  ├── README.md         # Documentation with usage examples
  ├── tests/
  │   └── unit/
  │       └── <module>_unit.tftest.hcl  # Unit tests (mock credentials)
  └── examples/
      ├── basic/        # Minimal usage example
      └── complete/     # Full-featured example
```

Common patterns across all modules:
- **Naming**: `${name}-${environment}` prefix on all resources
- **Tagging**: Common tags (Module, Environment, ManagedBy) merged with custom tags
- **Validation**: Input validation on environment, CIDRs, and enumerated values
- **Testing**: Plan-level tests covering core functionality and edge cases

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-module`)
3. Follow the module design conventions above
4. Add tests and examples for any new module
5. Run all quality checks before submitting
6. Submit a pull request

## License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.
