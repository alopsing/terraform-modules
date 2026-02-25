provider "aws" {
  region = "us-east-1"
}

variables {
  name        = "test"
  environment = "dev"
  bucket_name = "test-bucket-tftest-12345"
}

run "bucket_creation" {
  command = plan

  assert {
    condition     = aws_s3_bucket.this.bucket == "test-bucket-tftest-12345"
    error_message = "Bucket name does not match expected value."
  }
}

run "versioning_enabled_by_default" {
  command = plan

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning should be enabled by default."
  }
}

run "encryption_sse_s3_by_default" {
  command = plan

  assert {
    condition     = aws_s3_bucket_server_side_encryption_configuration.this.rule[0].apply_server_side_encryption_by_default[0].sse_algorithm == "AES256"
    error_message = "Default encryption should be SSE-S3 (AES256)."
  }
}

run "public_access_blocked" {
  command = plan

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls == true
    error_message = "Public ACLs should be blocked by default."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy == true
    error_message = "Public policy should be blocked by default."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.ignore_public_acls == true
    error_message = "Public ACLs should be ignored by default."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.restrict_public_buckets == true
    error_message = "Public buckets should be restricted by default."
  }
}

run "lifecycle_rules" {
  command = plan

  variables {
    lifecycle_rules = [
      {
        id              = "archive"
        enabled         = true
        prefix          = "logs/"
        expiration_days = 90
        transitions = [
          {
            days          = 30
            storage_class = "STANDARD_IA"
          }
        ]
      }
    ]
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 1
    error_message = "Lifecycle configuration should be created when rules are provided."
  }
}
