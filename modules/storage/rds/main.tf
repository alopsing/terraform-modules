# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-subnet-group"
  })
}

# Security Group
resource "aws_security_group" "this" {
  name_prefix = "${local.name_prefix}-rds-"
  description = "Security group for ${local.name_prefix} RDS instance"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress" {
  count = length(var.allowed_cidr_blocks) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = aws_db_instance.this.port
  to_port           = aws_db_instance.this.port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.this.id
  description       = "Allow inbound database traffic"
}

# Parameter Group (conditional)
resource "aws_db_parameter_group" "this" {
  count = local.create_parameter_group ? 1 : 0

  name_prefix = "${local.name_prefix}-"
  family      = var.parameter_group_family
  description = "Custom parameter group for ${local.name_prefix}"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-parameter-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Enhanced Monitoring IAM Role (conditional)
resource "aws_iam_role" "monitoring" {
  count = local.create_monitoring_role ? 1 : 0

  name_prefix        = "${local.name_prefix}-rds-monitoring-"
  assume_role_policy = data.aws_iam_policy_document.monitoring_assume_role[0].json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds-monitoring-role"
  })
}

data "aws_iam_policy_document" "monitoring_assume_role" {
  count = local.create_monitoring_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "monitoring" {
  count = local.create_monitoring_role ? 1 : 0

  role       = aws_iam_role.monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# RDS Instance
resource "aws_db_instance" "this" {
  identifier = var.identifier

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  db_name  = var.db_name
  username = var.username

  manage_master_user_password = var.manage_master_user_password

  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  parameter_group_name = local.create_parameter_group ? aws_db_parameter_group.this[0].name : null

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : local.final_snapshot_id
  deletion_protection       = var.deletion_protection

  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval          = var.monitoring_interval
  monitoring_role_arn          = local.create_monitoring_role ? aws_iam_role.monitoring[0].arn : null

  tags = merge(local.common_tags, {
    Name = var.identifier
  })
}
