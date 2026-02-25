locals {
  name_prefix = "${var.name}-${var.environment}"

  common_tags = merge(
    {
      Module      = "sqs"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )
}
