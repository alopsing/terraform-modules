provider "aws" {
  region = "us-east-1"
}

module "dynamodb_table" {
  source = "../../"

  name        = "myapp"
  environment = "prod"
  table_name  = "myapp-prod-orders"
  hash_key    = "order_id"
  range_key   = "created_at"

  attributes = [
    { name = "order_id", type = "S" },
    { name = "created_at", type = "S" },
    { name = "customer_id", type = "S" },
    { name = "status", type = "S" }
  ]

  global_secondary_indexes = [
    {
      name            = "customer-index"
      hash_key        = "customer_id"
      range_key       = "created_at"
      projection_type = "ALL"
    },
    {
      name            = "status-index"
      hash_key        = "status"
      projection_type = "ALL"
    }
  ]

  enable_encryption             = true
  enable_point_in_time_recovery = true

  ttl_attribute = "expires_at"

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = {
    Team       = "platform"
    CostCenter = "12345"
  }
}

output "table_arn" {
  value = module.dynamodb_table.table_arn
}

output "table_stream_arn" {
  value = module.dynamodb_table.table_stream_arn
}
