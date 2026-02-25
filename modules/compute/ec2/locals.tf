locals {
  name_prefix = "${var.name}-${var.environment}"

  common_tags = merge(
    {
      Module      = "ec2"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )
}
