# EC2 Module

Terraform module for creating EC2 instances with AMI lookup, EBS volumes, security groups, and IAM instance profiles.

## Usage

```hcl
module "ec2" {
  source = "path/to/modules/compute/ec2"

  name        = "my-app"
  environment = "dev"
  subnet_id   = "subnet-12345678"
  vpc_id      = "vpc-12345678"

  instance_type  = "t3.micro"
  instance_count = 2

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "SSH access"
    }
  ]

  tags = {
    Project = "example"
  }
}
```

## Features

- Automatic AMI lookup for Amazon Linux 2023 when `ami_id` is not provided
- Configurable security group with ingress and egress rules
- Additional EBS volume support with automatic attachment
- Support for user data, key pairs, and IAM instance profiles
- Encrypted root volumes by default

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name prefix for resources | `string` | n/a | yes |
| environment | Environment (dev, staging, prod) | `string` | n/a | yes |
| subnet_id | Subnet ID for instances | `string` | n/a | yes |
| vpc_id | VPC ID for security group | `string` | n/a | yes |
| tags | Additional tags | `map(string)` | `{}` | no |
| instance_count | Number of instances | `number` | `1` | no |
| ami_id | AMI ID (null = latest Amazon Linux 2023) | `string` | `null` | no |
| instance_type | EC2 instance type | `string` | `"t3.micro"` | no |
| associate_public_ip | Associate public IP | `bool` | `false` | no |
| key_name | Key pair name | `string` | `null` | no |
| user_data | User data script | `string` | `null` | no |
| iam_instance_profile | IAM instance profile name | `string` | `null` | no |
| root_volume_size | Root volume size (GB) | `number` | `20` | no |
| root_volume_type | Root volume type | `string` | `"gp3"` | no |
| root_volume_encrypted | Encrypt root volume | `bool` | `true` | no |
| additional_ebs_volumes | Additional EBS volumes | `list(object)` | `[]` | no |
| ingress_rules | Security group ingress rules | `list(object)` | `[]` | no |
| egress_rules | Security group egress rules | `list(object)` | Allow all outbound | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_ids | List of EC2 instance IDs |
| private_ips | List of private IP addresses |
| public_ips | List of public IP addresses |
| security_group_id | ID of the security group |

## Examples

- [Basic](examples/basic/) - Single instance with minimal configuration
- [Complete](examples/complete/) - Multiple instances with EBS volumes and full configuration
