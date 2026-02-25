locals {
  common_tags = merge(
    {
      Module      = "lambda"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )

  name_prefix = "${var.name}-${var.environment}"
  has_vpc     = length(var.vpc_subnet_ids) > 0
}
