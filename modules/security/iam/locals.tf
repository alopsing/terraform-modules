locals {
  common_tags = merge(
    {
      Module      = "iam"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )

  name_prefix = "${var.name}-${var.environment}"
}
