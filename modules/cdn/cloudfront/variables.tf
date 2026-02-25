variable "name" {
  description = "Name for the CloudFront distribution and related resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "comment" {
  description = "Comment for the CloudFront distribution"
  type        = string
  default     = ""
}

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution"
  type        = bool
  default     = true
}

variable "default_root_object" {
  description = "Default root object for the distribution"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "Price class for the distribution"
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "Price class must be one of: PriceClass_100, PriceClass_200, PriceClass_All."
  }
}

variable "aliases" {
  description = "List of CNAMEs (alternate domain names) for the distribution"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for custom domain SSL. Required when aliases are set."
  type        = string
  default     = null
}

variable "minimum_protocol_version" {
  description = "Minimum TLS protocol version for viewer connections"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "web_acl_id" {
  description = "WAF WebACL ARN to associate with the distribution"
  type        = string
  default     = null
}

variable "origins" {
  description = "List of origins for the distribution"
  type = list(object({
    domain_name = string
    origin_id   = string
    origin_type = string # "s3" or "custom"
    origin_path = optional(string, "")
    s3_origin_config = optional(object({
      origin_access_identity = optional(string, "")
    }), null)
    custom_origin_config = optional(object({
      http_port                = optional(number, 80)
      https_port               = optional(number, 443)
      origin_protocol_policy   = optional(string, "https-only")
      origin_ssl_protocols     = optional(list(string), ["TLSv1.2"])
      origin_keepalive_timeout = optional(number, 5)
      origin_read_timeout      = optional(number, 30)
    }), null)
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
  }))

  validation {
    condition     = length(var.origins) > 0
    error_message = "At least one origin must be specified."
  }

  validation {
    condition     = alltrue([for o in var.origins : contains(["s3", "custom"], o.origin_type)])
    error_message = "Origin type must be either 's3' or 'custom'."
  }
}

variable "default_cache_behavior" {
  description = "Default cache behavior for the distribution"
  type = object({
    allowed_methods        = optional(list(string), ["GET", "HEAD"])
    cached_methods         = optional(list(string), ["GET", "HEAD"])
    target_origin_id       = string
    viewer_protocol_policy = optional(string, "redirect-to-https")
    cache_policy_id        = optional(string, null)
    compress               = optional(bool, true)
    default_ttl            = optional(number, 86400)
    max_ttl                = optional(number, 31536000)
    min_ttl                = optional(number, 0)
    forwarded_values = optional(object({
      query_string = optional(bool, false)
      cookies = optional(object({
        forward = optional(string, "none")
      }), { forward = "none" })
      headers = optional(list(string), [])
    }), null)
  })
}

variable "ordered_cache_behaviors" {
  description = "Ordered list of cache behaviors for the distribution"
  type = list(object({
    path_pattern           = string
    allowed_methods        = optional(list(string), ["GET", "HEAD"])
    cached_methods         = optional(list(string), ["GET", "HEAD"])
    target_origin_id       = string
    viewer_protocol_policy = optional(string, "redirect-to-https")
    cache_policy_id        = optional(string, null)
    compress               = optional(bool, true)
    default_ttl            = optional(number, 86400)
    max_ttl                = optional(number, 31536000)
    min_ttl                = optional(number, 0)
    forwarded_values = optional(object({
      query_string = optional(bool, false)
      cookies = optional(object({
        forward = optional(string, "none")
      }), { forward = "none" })
      headers = optional(list(string), [])
    }), null)
  }))
  default = []
}

variable "custom_error_responses" {
  description = "List of custom error responses"
  type = list(object({
    error_code            = number
    response_code         = optional(number, null)
    response_page_path    = optional(string, null)
    error_caching_min_ttl = optional(number, 300)
  }))
  default = []
}

variable "create_oac" {
  description = "Whether to create an Origin Access Control for S3 origins"
  type        = bool
  default     = false
}

variable "logging_config" {
  description = "Logging configuration for the distribution"
  type = object({
    bucket          = string
    prefix          = optional(string, "")
    include_cookies = optional(bool, false)
  })
  default = null
}
