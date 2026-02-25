# Three-Tier Web Application

This example deploys a classic three-tier architecture on AWS.

## Architecture

```
Internet -> CloudFront -> EC2 (Web/App) -> RDS (PostgreSQL)
                |
                v
            S3 (Static Assets)
```

## Modules Used

| Module | Purpose |
|--------|---------|
| [VPC](../../modules/networking/vpc/) | Network foundation with public/private subnets |
| [EC2](../../modules/compute/ec2/) | Web/application servers |
| [RDS](../../modules/storage/rds/) | PostgreSQL database |
| [S3](../../modules/storage/s3/) | Static asset storage |
| [CloudFront](../../modules/cdn/cloudfront/) | CDN for static assets |

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| project_name | Project name | `three-tier-app` |
| environment | Environment (dev/staging/prod) | `dev` |
| aws_region | AWS region | `us-east-1` |
| web_instance_count | Number of web servers | `2` |
| db_instance_class | RDS instance class | `db.t3.micro` |
