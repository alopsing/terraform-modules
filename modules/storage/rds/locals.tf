locals {
  name_prefix = "${var.name}-${var.environment}"

  common_tags = merge(
    {
      Module      = "rds"
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )

  create_parameter_group = var.parameter_group_family != null
  create_monitoring_role = var.monitoring_interval > 0
  final_snapshot_id      = var.final_snapshot_identifier != null ? var.final_snapshot_identifier : "${local.name_prefix}-final-snapshot"

  # Default port by engine family, used when var.port is not set. Resolving the
  # port here (rather than reading it back off the instance) keeps it known at
  # plan time and avoids an implicit security-group <-> instance dependency.
  default_ports = {
    mysql     = 3306
    mariadb   = 3306
    postgres  = 5432
    oracle    = 1521
    sqlserver = 1433
  }
  engine_family = regex("^[a-z]+", var.engine)
  port          = var.port != null ? var.port : lookup(local.default_ports, local.engine_family, 3306)
}
