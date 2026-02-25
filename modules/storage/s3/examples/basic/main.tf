provider "aws" {
  region = "us-east-1"
}

module "s3_bucket" {
  source = "../../"

  name        = "myapp"
  environment = "dev"
  bucket_name = "myapp-dev-data-bucket"

  tags = {
    Team = "platform"
  }
}

output "bucket_arn" {
  value = module.s3_bucket.bucket_arn
}
