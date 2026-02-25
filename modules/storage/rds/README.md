# RDS Module

Terraform module for creating and managing AWS RDS instances with best-practice defaults including encryption, automated backups, and enhanced monitoring.

## Features

- Multiple engine support (MySQL, PostgreSQL, etc.)
- Multi-AZ deployments
- DB subnet group management
- Custom parameter groups (conditional)
- Security group with configurable CIDR access
- Automated backups with configurable retention
- Storage encryption (enabled by default)
- AWS Secrets Manager integration for master password
- Performance Insights
- Enhanced monitoring with automatic IAM role creation
- Deletion protection (enabled by default)
- Storage autoscaling

## Usage

### Basic

```hcl
module "rds" {
  source = "../../modules/storage/rds"

  name        = "myapp"
  environment = "dev"
  identifier  = "myapp-dev-db"

  engine         = "postgres"
  engine_version = "15.4"

  subnet_ids = ["subnet-abc123", "subnet-def456"]
  vpc_id     = "vpc-123456"

  skip_final_snapshot = true
  deletion_protection = false
}
```

### Production with Custom Parameters

```hcl
module "rds" {
  source = "../../modules/storage/rds"

  name        = "myapp"
  environment = "prod"
  identifier  = "myapp-prod-db"

  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.r6g.large"

  allocated_storage     = 100
  max_allocated_storage = 500
  multi_az              = true

  subnet_ids          = ["subnet-abc", "subnet-def", "subnet-ghi"]
  vpc_id              = "vpc-123456"
  allowed_cidr_blocks = ["10.0.0.0/16"]

  backup_retention_period = 14
  monitoring_interval     = 30

  parameter_group_family = "postgres15"
  parameters = {
    "shared_buffers" = "256000"
    "max_connections" = "200"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name for module resources | string | - | yes |
| environment | Environment (dev/staging/prod) | string | - | yes |
| tags | Additional tags | map(string) | {} | no |
| identifier | RDS instance identifier | string | - | yes |
| engine | Database engine | string | - | yes |
| engine_version | Engine version | string | - | yes |
| instance_class | Instance class | string | "db.t3.micro" | no |
| allocated_storage | Storage in GB | number | 20 | no |
| max_allocated_storage | Max storage in GB | number | 100 | no |
| storage_encrypted | Enable encryption | bool | true | no |
| kms_key_id | KMS key ARN | string | null | no |
| db_name | Default database name | string | null | no |
| username | Master username | string | "admin" | no |
| manage_master_user_password | Use Secrets Manager | bool | true | no |
| multi_az | Enable Multi-AZ | bool | false | no |
| subnet_ids | Subnet IDs | list(string) | - | yes |
| vpc_id | VPC ID | string | - | yes |
| allowed_cidr_blocks | Allowed CIDRs | list(string) | [] | no |
| backup_retention_period | Backup retention days | number | 7 | no |
| backup_window | Backup window | string | "03:00-04:00" | no |
| maintenance_window | Maintenance window | string | "Mon:04:00-Mon:05:00" | no |
| skip_final_snapshot | Skip final snapshot | bool | false | no |
| final_snapshot_identifier | Final snapshot ID | string | null | no |
| deletion_protection | Enable deletion protection | bool | true | no |
| performance_insights_enabled | Enable Performance Insights | bool | true | no |
| monitoring_interval | Monitoring interval (seconds) | number | 60 | no |
| parameter_group_family | Parameter group family | string | null | no |
| parameters | DB parameters | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| db_instance_id | The ID of the RDS instance |
| db_instance_arn | The ARN of the RDS instance |
| db_instance_endpoint | The connection endpoint |
| db_instance_port | The port of the RDS instance |
| db_security_group_id | The security group ID |
