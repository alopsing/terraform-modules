locals {
  name_prefix = "${var.name}-${var.environment}"

  common_tags = merge(
    {
      Module      = "cloudfront"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )

  s3_origins     = [for o in var.origins : o if o.origin_type == "s3"]
  custom_origins = [for o in var.origins : o if o.origin_type == "custom"]

  # Determine viewer certificate configuration
  use_custom_certificate = var.acm_certificate_arn != null && length(var.aliases) > 0
}
