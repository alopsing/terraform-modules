provider "aws" {
  region = "us-east-1"
}

module "rds" {
  source = "../../"

  name        = "myapp"
  environment = "prod"
  identifier  = "myapp-prod-db"

  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.r6g.large"

  allocated_storage     = 100
  max_allocated_storage = 500
  storage_encrypted     = true

  db_name  = "myappdb"
  username = "dbadmin"

  manage_master_user_password = true

  multi_az = true

  subnet_ids          = ["subnet-12345678", "subnet-87654321", "subnet-11223344"]
  vpc_id              = "vpc-12345678"
  allowed_cidr_blocks = ["10.0.0.0/16"]

  backup_retention_period = 14
  backup_window           = "02:00-03:00"
  maintenance_window      = "Sun:03:00-Sun:04:00"

  skip_final_snapshot       = false
  final_snapshot_identifier = "myapp-prod-db-final"
  deletion_protection       = true

  performance_insights_enabled = true
  monitoring_interval          = 30

  parameter_group_family = "postgres15"
  parameters = {
    "shared_buffers"  = "256000"
    "max_connections" = "200"
    "log_statement"   = "all"
  }

  tags = {
    Team       = "platform"
    CostCenter = "12345"
    Compliance = "soc2"
  }
}

output "db_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "db_port" {
  value = module.rds.db_instance_port
}

output "db_security_group_id" {
  value = module.rds.db_security_group_id
}
