# S3 Bucket Module

Terraform module for creating and managing AWS S3 buckets with best-practice defaults including encryption, versioning, and public access blocking.

## Features

- Server-side encryption (SSE-S3 or SSE-KMS)
- Bucket versioning
- Lifecycle rules with transitions and expiration
- CORS configuration
- Access logging
- Bucket policy support
- Public access block (all blocked by default)

## Usage

### Basic

```hcl
module "s3_bucket" {
  source = "../../modules/storage/s3"

  name        = "myapp"
  environment = "dev"
  bucket_name = "myapp-dev-data"
}
```

### With KMS Encryption and Lifecycle Rules

```hcl
module "s3_bucket" {
  source = "../../modules/storage/s3"

  name        = "myapp"
  environment = "prod"
  bucket_name = "myapp-prod-data"

  encryption_type = "SSE-KMS"
  kms_key_arn     = "arn:aws:kms:us-east-1:123456789012:key/example"

  lifecycle_rules = [
    {
      id              = "archive"
      enabled         = true
      prefix          = "logs/"
      expiration_days = 90
      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
        { days = 60, storage_class = "GLACIER" }
      ]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name for module resources | string | - | yes |
| environment | Environment (dev/staging/prod) | string | - | yes |
| tags | Additional tags | map(string) | {} | no |
| bucket_name | S3 bucket name | string | - | yes |
| enable_versioning | Enable versioning | bool | true | no |
| encryption_type | SSE-S3 or SSE-KMS | string | "SSE-S3" | no |
| kms_key_arn | KMS key ARN for SSE-KMS | string | null | no |
| lifecycle_rules | Lifecycle rules | list(object) | [] | no |
| cors_rules | CORS rules | list(object) | [] | no |
| logging_target_bucket | Access log target bucket | string | null | no |
| logging_target_prefix | Access log prefix | string | "logs/" | no |
| bucket_policy | JSON bucket policy | string | null | no |
| block_public_access | Block all public access | bool | true | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name of the S3 bucket |
| bucket_arn | The ARN of the S3 bucket |
| bucket_domain_name | The bucket domain name |
| bucket_regional_domain_name | The bucket region-specific domain name |
