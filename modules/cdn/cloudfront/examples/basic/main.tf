provider "aws" {
  region = "us-east-1"
}

module "cloudfront" {
  source = "../../"

  name        = "my-website"
  environment = "dev"

  origins = [
    {
      domain_name = "my-website-bucket.s3.us-east-1.amazonaws.com"
      origin_id   = "s3-my-website"
      origin_type = "s3"
    }
  ]

  default_cache_behavior = {
    target_origin_id       = "s3-my-website"
    viewer_protocol_policy = "redirect-to-https"
  }

  tags = {
    Project = "my-website"
  }
}

output "distribution_domain_name" {
  value = module.cloudfront.distribution_domain_name
}

output "distribution_id" {
  value = module.cloudfront.distribution_id
}
