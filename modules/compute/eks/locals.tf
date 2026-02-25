locals {
  name_prefix = "${var.name}-${var.environment}"

  common_tags = merge(
    {
      Module      = "eks"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )
}
