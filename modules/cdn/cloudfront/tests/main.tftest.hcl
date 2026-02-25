provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Testing = "true"
    }
  }
}

################################################################################
# Test: Basic S3 Origin Distribution
################################################################################

run "creates_basic_s3_distribution" {
  command = plan

  variables {
    name        = "test-cdn"
    environment = "dev"

    origins = [
      {
        domain_name = "test-bucket.s3.us-east-1.amazonaws.com"
        origin_id   = "s3-test-bucket"
        origin_type = "s3"
      }
    ]

    default_cache_behavior = {
      target_origin_id = "s3-test-bucket"
    }
  }

  assert {
    condition     = aws_cloudfront_distribution.this.enabled == true
    error_message = "Distribution should be enabled by default."
  }

  assert {
    condition     = aws_cloudfront_distribution.this.is_ipv6_enabled == true
    error_message = "IPv6 should be enabled by default."
  }

  assert {
    condition     = aws_cloudfront_distribution.this.default_root_object == "index.html"
    error_message = "Default root object should be index.html."
  }

  assert {
    condition     = aws_cloudfront_distribution.this.price_class == "PriceClass_100"
    error_message = "Price class should be PriceClass_100 by default."
  }
}

################################################################################
# Test: Distribution with OAC
################################################################################

run "creates_distribution_with_oac" {
  command = plan

  variables {
    name        = "test-cdn-oac"
    environment = "prod"
    create_oac  = true

    origins = [
      {
        domain_name = "test-bucket.s3.us-east-1.amazonaws.com"
        origin_id   = "s3-test-bucket"
        origin_type = "s3"
      }
    ]

    default_cache_behavior = {
      target_origin_id = "s3-test-bucket"
    }
  }

  assert {
    condition     = aws_cloudfront_origin_access_control.this[0].origin_access_control_origin_type == "s3"
    error_message = "OAC should be created for S3 origin type."
  }

  assert {
    condition     = aws_cloudfront_origin_access_control.this[0].signing_behavior == "always"
    error_message = "OAC signing behavior should be 'always'."
  }

  assert {
    condition     = aws_cloudfront_origin_access_control.this[0].signing_protocol == "sigv4"
    error_message = "OAC signing protocol should be 'sigv4'."
  }
}

################################################################################
# Test: Custom Error Responses
################################################################################

run "creates_distribution_with_custom_error_responses" {
  command = plan

  variables {
    name        = "test-cdn-errors"
    environment = "staging"

    origins = [
      {
        domain_name = "test-bucket.s3.us-east-1.amazonaws.com"
        origin_id   = "s3-test-bucket"
        origin_type = "s3"
      }
    ]

    default_cache_behavior = {
      target_origin_id = "s3-test-bucket"
    }

    custom_error_responses = [
      {
        error_code         = 404
        response_code      = 200
        response_page_path = "/index.html"
      },
      {
        error_code         = 403
        response_code      = 200
        response_page_path = "/index.html"
      }
    ]
  }

  assert {
    condition     = aws_cloudfront_distribution.this.enabled == true
    error_message = "Distribution should be enabled."
  }
}

################################################################################
# Test: Custom Origin (ALB)
################################################################################

run "creates_distribution_with_custom_origin" {
  command = plan

  variables {
    name        = "test-cdn-alb"
    environment = "prod"

    origins = [
      {
        domain_name = "my-alb-123456.us-east-1.elb.amazonaws.com"
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
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD"]
      target_origin_id       = "alb-origin"
      viewer_protocol_policy = "redirect-to-https"
    }
  }

  assert {
    condition     = aws_cloudfront_distribution.this.enabled == true
    error_message = "Distribution with custom origin should be enabled."
  }
}

################################################################################
# Test: Caching with Cache Policy
################################################################################

run "creates_distribution_with_cache_policy" {
  command = plan

  variables {
    name        = "test-cdn-cache"
    environment = "dev"

    origins = [
      {
        domain_name = "test-bucket.s3.us-east-1.amazonaws.com"
        origin_id   = "s3-test-bucket"
        origin_type = "s3"
      }
    ]

    default_cache_behavior = {
      target_origin_id = "s3-test-bucket"
      cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
      compress         = true
    }
  }

  assert {
    condition     = aws_cloudfront_distribution.this.default_cache_behavior[0].compress == true
    error_message = "Compression should be enabled."
  }
}
