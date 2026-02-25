provider "aws" {
  region = "us-east-1"
}

variables {
  name           = "test"
  environment    = "dev"
  identifier     = "test-db"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  subnet_ids     = ["subnet-12345678", "subnet-87654321"]
  vpc_id         = "vpc-12345678"
}

run "instance_creation" {
  command = plan

  assert {
    condition     = aws_db_instance.this.identifier == "test-db"
    error_message = "DB identifier does not match expected value."
  }

  assert {
    condition     = aws_db_instance.this.engine == "postgres"
    error_message = "DB engine does not match expected value."
  }

  assert {
    condition     = aws_db_instance.this.engine_version == "15.4"
    error_message = "DB engine version does not match expected value."
  }

  assert {
    condition     = aws_db_instance.this.instance_class == "db.t3.micro"
    error_message = "DB instance class does not match expected value."
  }
}

run "encryption_enabled" {
  command = plan

  assert {
    condition     = aws_db_instance.this.storage_encrypted == true
    error_message = "Storage encryption should be enabled by default."
  }
}

run "multi_az_disabled_by_default" {
  command = plan

  assert {
    condition     = aws_db_instance.this.multi_az == false
    error_message = "Multi-AZ should be disabled by default."
  }
}

run "backup_configuration" {
  command = plan

  assert {
    condition     = aws_db_instance.this.backup_retention_period == 7
    error_message = "Backup retention period should default to 7 days."
  }

  assert {
    condition     = aws_db_instance.this.backup_window == "03:00-04:00"
    error_message = "Backup window should default to 03:00-04:00."
  }
}
