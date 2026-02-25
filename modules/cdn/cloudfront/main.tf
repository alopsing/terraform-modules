################################################################################
# Origin Access Control (OAC) for S3 Origins
################################################################################

resource "aws_cloudfront_origin_access_control" "this" {
  count = var.create_oac ? 1 : 0

  name                              = "${local.name_prefix}-oac"
  description                       = "OAC for ${local.name_prefix} CloudFront distribution"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

################################################################################
# CloudFront Distribution
################################################################################

resource "aws_cloudfront_distribution" "this" {
  comment             = var.comment != "" ? var.comment : "${local.name_prefix} distribution"
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = var.aliases
  web_acl_id          = var.web_acl_id

  # S3 Origins
  dynamic "origin" {
    for_each = local.s3_origins
    content {
      domain_name              = origin.value.domain_name
      origin_id                = origin.value.origin_id
      origin_path              = origin.value.origin_path
      origin_access_control_id = var.create_oac ? aws_cloudfront_origin_access_control.this[0].id : null

      dynamic "custom_header" {
        for_each = origin.value.custom_headers
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  # Custom Origins (ALB, API Gateway, etc.)
  dynamic "origin" {
    for_each = local.custom_origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id
      origin_path = origin.value.origin_path

      custom_origin_config {
        http_port                = origin.value.custom_origin_config != null ? origin.value.custom_origin_config.http_port : 80
        https_port               = origin.value.custom_origin_config != null ? origin.value.custom_origin_config.https_port : 443
        origin_protocol_policy   = origin.value.custom_origin_config != null ? origin.value.custom_origin_config.origin_protocol_policy : "https-only"
        origin_ssl_protocols     = origin.value.custom_origin_config != null ? origin.value.custom_origin_config.origin_ssl_protocols : ["TLSv1.2"]
        origin_keepalive_timeout = origin.value.custom_origin_config != null ? origin.value.custom_origin_config.origin_keepalive_timeout : 5
        origin_read_timeout      = origin.value.custom_origin_config != null ? origin.value.custom_origin_config.origin_read_timeout : 30
      }

      dynamic "custom_header" {
        for_each = origin.value.custom_headers
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  # Default Cache Behavior
  default_cache_behavior {
    allowed_methods        = var.default_cache_behavior.allowed_methods
    cached_methods         = var.default_cache_behavior.cached_methods
    target_origin_id       = var.default_cache_behavior.target_origin_id
    viewer_protocol_policy = var.default_cache_behavior.viewer_protocol_policy
    compress               = var.default_cache_behavior.compress
    cache_policy_id        = var.default_cache_behavior.cache_policy_id

    # Use forwarded_values only when cache_policy_id is not set
    dynamic "forwarded_values" {
      for_each = var.default_cache_behavior.cache_policy_id == null ? [1] : []
      content {
        query_string = var.default_cache_behavior.forwarded_values != null ? var.default_cache_behavior.forwarded_values.query_string : false
        headers      = var.default_cache_behavior.forwarded_values != null ? var.default_cache_behavior.forwarded_values.headers : []

        cookies {
          forward = var.default_cache_behavior.forwarded_values != null ? var.default_cache_behavior.forwarded_values.cookies.forward : "none"
        }
      }
    }

    default_ttl = var.default_cache_behavior.cache_policy_id == null ? var.default_cache_behavior.default_ttl : null
    max_ttl     = var.default_cache_behavior.cache_policy_id == null ? var.default_cache_behavior.max_ttl : null
    min_ttl     = var.default_cache_behavior.cache_policy_id == null ? var.default_cache_behavior.min_ttl : null
  }

  # Ordered Cache Behaviors
  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors
    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      compress               = ordered_cache_behavior.value.compress
      cache_policy_id        = ordered_cache_behavior.value.cache_policy_id

      dynamic "forwarded_values" {
        for_each = ordered_cache_behavior.value.cache_policy_id == null ? [1] : []
        content {
          query_string = ordered_cache_behavior.value.forwarded_values != null ? ordered_cache_behavior.value.forwarded_values.query_string : false
          headers      = ordered_cache_behavior.value.forwarded_values != null ? ordered_cache_behavior.value.forwarded_values.headers : []

          cookies {
            forward = ordered_cache_behavior.value.forwarded_values != null ? ordered_cache_behavior.value.forwarded_values.cookies.forward : "none"
          }
        }
      }

      default_ttl = ordered_cache_behavior.value.cache_policy_id == null ? ordered_cache_behavior.value.default_ttl : null
      max_ttl     = ordered_cache_behavior.value.cache_policy_id == null ? ordered_cache_behavior.value.max_ttl : null
      min_ttl     = ordered_cache_behavior.value.cache_policy_id == null ? ordered_cache_behavior.value.min_ttl : null
    }
  }

  # Custom Error Responses
  dynamic "custom_error_response" {
    for_each = var.custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  # Logging
  dynamic "logging_config" {
    for_each = var.logging_config != null ? [var.logging_config] : []
    content {
      bucket          = logging_config.value.bucket
      prefix          = logging_config.value.prefix
      include_cookies = logging_config.value.include_cookies
    }
  }

  # Viewer Certificate
  viewer_certificate {
    cloudfront_default_certificate = !local.use_custom_certificate
    acm_certificate_arn            = local.use_custom_certificate ? var.acm_certificate_arn : null
    ssl_support_method             = local.use_custom_certificate ? "sni-only" : null
    minimum_protocol_version       = local.use_custom_certificate ? var.minimum_protocol_version : null
  }

  # Restrictions (required block)
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = local.common_tags
}
