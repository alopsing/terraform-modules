locals {
  name_prefix = "${var.name}-${var.environment}"

  common_tags = merge(
    {
      Module      = "sns"
      Name        = local.name_prefix
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )
}
