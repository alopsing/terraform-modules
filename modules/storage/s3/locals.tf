locals {
  name_prefix = "${var.name}-${var.environment}"

  common_tags = merge(
    {
      Module      = "s3"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}
