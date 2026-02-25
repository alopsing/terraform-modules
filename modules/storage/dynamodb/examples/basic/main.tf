provider "aws" {
  region = "us-east-1"
}

module "dynamodb_table" {
  source = "../../"

  name        = "myapp"
  environment = "dev"
  table_name  = "myapp-dev-users"
  hash_key    = "user_id"

  attributes = [
    { name = "user_id", type = "S" }
  ]

  tags = {
    Team = "platform"
  }
}

output "table_arn" {
  value = module.dynamodb_table.table_arn
}
