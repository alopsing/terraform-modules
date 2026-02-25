# CloudFront Distribution Module

Terraform module for creating and managing Amazon CloudFront distributions with support for S3 and custom (ALB/API Gateway) origins, Origin Access Control (OAC), custom error responses, cache behaviors, SSL certificates, and WAF integration.

## Usage

### Basic S3 Origin

```hcl
module "cloudfront" {
  source = "path/to/modules/cdn/cloudfront"

  name        = "my-website"
  environment = "dev"

  origins = [
    {
      domain_name = "my-bucket.s3.us-east-1.amazonaws.com"
      origin_id   = "s3-my-bucket"
      origin_type = "s3"
    }
  ]

  default_cache_behavior = {
    target_origin_id       = "s3-my-bucket"
    viewer_protocol_policy = "redirect-to-https"
  }
}
```

### S3 Origin with OAC

```hcl
module "cloudfront" {
  source = "path/to/modules/cdn/cloudfront"

  name        = "my-secure-site"
  environment = "prod"
  create_oac  = true

  origins = [
    {
      domain_name = "my-bucket.s3.us-east-1.amazonaws.com"
      origin_id   = "s3-my-bucket"
      origin_type = "s3"
    }
  ]

  default_cache_behavior = {
    target_origin_id = "s3-my-bucket"
    cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }
}
```

### Custom Origin (ALB)

```hcl
module "cloudfront" {
  source = "path/to/modules/cdn/cloudfront"

  name        = "my-app"
  environment = "prod"

  aliases             = ["app.example.com"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/cert-id"

  origins = [
    {
      domain_name = "my-alb.us-east-1.elb.amazonaws.com"
      origin_id   = "alb-origin"
      origin_type = "custom"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  ]

  default_cache_behavior = {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb-origin"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name for the CloudFront distribution | `string` | n/a | yes |
| environment | Environment name (dev, staging, prod) | `string` | n/a | yes |
| tags | Additional tags to apply | `map(string)` | `{}` | no |
| comment | Comment for the distribution | `string` | `""` | no |
| enabled | Whether the distribution is enabled | `bool` | `true` | no |
| is_ipv6_enabled | Whether IPv6 is enabled | `bool` | `true` | no |
| default_root_object | Default root object | `string` | `"index.html"` | no |
| price_class | Price class for the distribution | `string` | `"PriceClass_100"` | no |
| aliases | List of CNAMEs for the distribution | `list(string)` | `[]` | no |
| acm_certificate_arn | ACM certificate ARN for custom SSL | `string` | `null` | no |
| minimum_protocol_version | Minimum TLS protocol version | `string` | `"TLSv1.2_2021"` | no |
| web_acl_id | WAF WebACL ARN | `string` | `null` | no |
| origins | List of origins | `list(object)` | n/a | yes |
| default_cache_behavior | Default cache behavior configuration | `object` | n/a | yes |
| ordered_cache_behaviors | Ordered list of cache behaviors | `list(object)` | `[]` | no |
| custom_error_responses | List of custom error responses | `list(object)` | `[]` | no |
| create_oac | Whether to create Origin Access Control | `bool` | `false` | no |
| logging_config | Logging configuration | `object` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| distribution_id | The ID of the CloudFront distribution |
| distribution_arn | The ARN of the CloudFront distribution |
| distribution_domain_name | The domain name of the distribution |
| distribution_hosted_zone_id | The Route 53 zone ID for alias records |
| oac_id | The ID of the Origin Access Control (if created) |

## Resources Created

- `aws_cloudfront_distribution` - The CloudFront distribution
- `aws_cloudfront_origin_access_control` - Origin Access Control for S3 origins (conditional)

## Notes

- ACM certificates for CloudFront must be created in `us-east-1` region
- When using custom domains (`aliases`), an `acm_certificate_arn` is required
- OAC is the recommended way to restrict S3 access (replaces legacy OAI)
- WAF WebACL must be a global (CloudFront) WAF, not a regional one
