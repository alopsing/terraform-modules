provider "aws" {
  region = "us-east-1"
}

module "s3_bucket" {
  source = "../../"

  name        = "myapp"
  environment = "prod"
  bucket_name = "myapp-prod-data-bucket"

  enable_versioning = true
  encryption_type   = "SSE-KMS"
  kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/example-key-id"

  block_public_access = true

  lifecycle_rules = [
    {
      id              = "archive-logs"
      enabled         = true
      prefix          = "logs/"
      expiration_days = 365
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    },
    {
      id              = "cleanup-tmp"
      enabled         = true
      prefix          = "tmp/"
      expiration_days = 7
      transitions     = []
    }
  ]

  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT"]
      allowed_origins = ["https://example.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3600
    }
  ]

  logging_target_bucket = "myapp-prod-access-logs"
  logging_target_prefix = "s3-logs/"

  tags = {
    Team       = "platform"
    CostCenter = "12345"
    Compliance = "pci"
  }
}

output "bucket_arn" {
  value = module.s3_bucket.bucket_arn
}

output "bucket_domain_name" {
  value = module.s3_bucket.bucket_domain_name
}
