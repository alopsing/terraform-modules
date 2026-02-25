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
}
