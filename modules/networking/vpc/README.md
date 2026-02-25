# AWS VPC Module

Terraform module to create a production-ready AWS VPC with public and private subnets, NAT gateways, and optional VPC flow logs.

## Features

- Multi-AZ VPC with public and private subnets
- Internet Gateway for public subnets
- NAT Gateway (single or per-AZ) for private subnet internet access
- VPC Flow Logs with CloudWatch Logs or S3 destination
- Configurable DNS settings
- Consistent resource tagging

## Usage

### Basic

```hcl
module "vpc" {
  source = "../../modules/networking/vpc"

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

### Complete (with Flow Logs)

```hcl
module "vpc" {
  source = "../../modules/networking/vpc"

  name        = "production-app"
  environment = "prod"
  cidr_block  = "10.0.0.0/16"

  azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway        = true
  single_nat_gateway        = false
  enable_flow_logs          = true
  flow_log_destination_type = "cloud-watch-logs"
}
```

## Examples

- [Basic](examples/basic/) — Simple VPC with single NAT gateway
- [Complete](examples/complete/) — Production VPC with per-AZ NAT gateways and flow logs

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the VPC | `string` | n/a | yes |
| environment | Environment name (dev, staging, prod) | `string` | n/a | yes |
| azs | List of availability zones | `list(string)` | n/a | yes |
| cidr\_block | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| public\_subnet\_cidrs | CIDR blocks for public subnets | `list(string)` | `[]` | no |
| private\_subnet\_cidrs | CIDR blocks for private subnets | `list(string)` | `[]` | no |
| enable\_nat\_gateway | Enable NAT gateway for private subnets | `bool` | `true` | no |
| single\_nat\_gateway | Use a single NAT gateway instead of one per AZ | `bool` | `false` | no |
| enable\_dns\_hostnames | Enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable\_dns\_support | Enable DNS support in the VPC | `bool` | `true` | no |
| enable\_flow\_logs | Enable VPC flow logs | `bool` | `false` | no |
| flow\_log\_destination\_type | Type of flow log destination | `string` | `"cloud-watch-logs"` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc\_id | The ID of the VPC |
| vpc\_cidr | The CIDR block of the VPC |
| public\_subnet\_ids | List of public subnet IDs |
| private\_subnet\_ids | List of private subnet IDs |
| nat\_gateway\_ids | List of NAT gateway IDs |
| igw\_id | The ID of the Internet Gateway |
<!-- END_TF_DOCS -->
