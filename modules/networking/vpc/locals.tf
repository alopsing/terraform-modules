locals {
  common_tags = merge(
    {
      Module      = "vpc"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )

  name_prefix = "${var.name}-${var.environment}"

  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
}
