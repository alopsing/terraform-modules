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

  # Map each public CIDR to its AZ
  public_subnets = { for i, cidr in var.public_subnet_cidrs : cidr => {
    az = var.azs[i % length(var.azs)]
  } }

  # Map each private CIDR to its AZ
  private_subnets = { for i, cidr in var.private_subnet_cidrs : cidr => {
    az = var.azs[i % length(var.azs)]
  } }

  # AZs that need NAT gateways
  nat_azs = var.enable_nat_gateway ? (var.single_nat_gateway ? toset([var.azs[0]]) : toset(var.azs)) : toset([])

  # Map AZ to public subnet CIDR (for NAT gateway placement in public subnets)
  az_to_public_subnet_cidr = { for i, cidr in var.public_subnet_cidrs : var.azs[i % length(var.azs)] => cidr }

  # Private route table keys: one per NAT AZ, or a single "default" if no NAT but private subnets exist
  private_route_table_keys = length(local.nat_azs) > 0 ? local.nat_azs : (length(var.private_subnet_cidrs) > 0 ? toset(["default"]) : toset([]))
}
