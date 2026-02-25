provider "aws" {
  region = "us-east-1"
}

module "rds" {
  source = "../../"

  name        = "myapp"
  environment = "dev"
  identifier  = "myapp-dev-db"

  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"

  subnet_ids = ["subnet-12345678", "subnet-87654321"]
  vpc_id     = "vpc-12345678"

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Team = "platform"
  }
}

output "db_endpoint" {
  value = module.rds.db_instance_endpoint
}
