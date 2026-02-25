provider "aws" {
  region = "us-east-1"
}

module "cloudfront" {
  source = "../../"

  name        = "my-app"
  environment = "prod"
  comment     = "Production application CDN"

  # Enable OAC for S3 origins
  create_oac = true

  # Custom domain configuration
  aliases             = ["cdn.example.com", "www.example.com"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/example-cert-id"

  # Price class for global distribution
  price_class = "PriceClass_200"

  # WAF integration
  web_acl_id = "arn:aws:wafv2:us-east-1:123456789012:global/webacl/my-web-acl/example-id"

  # Multiple origins
  origins = [
    {
      domain_name = "my-app-static.s3.us-east-1.amazonaws.com"
      origin_id   = "s3-static"
      origin_type = "s3"
    },
    {
      domain_name = "my-app-alb-123456.us-east-1.elb.amazonaws.com"
      origin_id   = "alb-api"
      origin_type = "custom"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  ]

  # Default behavior for S3 static content
  default_cache_behavior = {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-static"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
  }

  # API behavior with different cache settings
  ordered_cache_behaviors = [
    {
      path_pattern           = "/api/*"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = "alb-api"
      viewer_protocol_policy = "https-only"
      compress               = true
      default_ttl            = 0
      max_ttl                = 0
      min_ttl                = 0
      forwarded_values = {
        query_string = true
        cookies = {
          forward = "all"
        }
        headers = ["Authorization", "Host"]
      }
    }
  ]

  # Custom error responses for SPA
  custom_error_responses = [
    {
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 60
    },
    {
      error_code            = 403
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 60
    }
  ]

  # Access logging
  logging_config = {
    bucket          = "my-app-logs.s3.amazonaws.com"
    prefix          = "cloudfront/"
    include_cookies = false
  }

  tags = {
    Project = "my-app"
    Team    = "platform"
  }
}

output "distribution_id" {
  value = module.cloudfront.distribution_id
}

output "distribution_domain_name" {
  value = module.cloudfront.distribution_domain_name
}

output "distribution_arn" {
  value = module.cloudfront.distribution_arn
}

output "oac_id" {
  value = module.cloudfront.oac_id
}
