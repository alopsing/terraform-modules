################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(local.common_tags, {
    Name = local.name_prefix
  })
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

################################################################################
# Public Subnets
################################################################################

resource "aws_subnet" "public" { #trivy:ignore:AVD-AWS-0164 -- Public subnets require public IP mapping by design
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.key
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-${each.value.az}"
    Tier = "public"
  })
}

resource "aws_route_table" "public" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  count = length(var.public_subnet_cidrs) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[0].id
}

################################################################################
# Private Subnets
################################################################################

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.key
  availability_zone = each.value.az

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-${each.value.az}"
    Tier = "private"
  })
}

resource "aws_route_table" "private" {
  for_each = local.private_route_table_keys

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt-${each.key}"
  })
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[
    length(local.nat_azs) > 1 ? each.value.az : keys(aws_route_table.private)[0]
  ].id
}

################################################################################
# NAT Gateway
################################################################################

resource "aws_eip" "nat" {
  for_each = local.nat_azs

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-eip-${each.key}"
  })
}

resource "aws_nat_gateway" "this" {
  for_each = local.nat_azs

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[local.az_to_public_subnet_cidr[each.key]].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-${each.key}"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat" {
  for_each = local.nat_azs

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

################################################################################
# Flow Logs
################################################################################

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id               = aws_vpc.this.id
  traffic_type         = "ALL"
  log_destination_type = var.flow_log_destination_type
  iam_role_arn         = var.flow_log_destination_type == "cloud-watch-logs" ? aws_iam_role.flow_log[0].arn : null
  log_destination      = var.flow_log_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.flow_log[0].arn : null

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-flow-log"
  })
}

resource "aws_cloudwatch_log_group" "flow_log" {
  count = var.enable_flow_logs && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0

  name              = "/aws/vpc-flow-log/${local.name_prefix}"
  retention_in_days = 30

  tags = local.common_tags
}

resource "aws_iam_role" "flow_log" {
  count = var.enable_flow_logs && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0

  name = "${local.name_prefix}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "flow_log" {
  count = var.enable_flow_logs && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0

  name = "${local.name_prefix}-flow-log-policy"
  role = aws_iam_role.flow_log[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
