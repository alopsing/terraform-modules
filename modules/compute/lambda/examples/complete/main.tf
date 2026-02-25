provider "aws" {
  region = "us-east-1"
}

module "lambda" {
  source = "../../"

  name          = "production-app"
  environment   = "prod"
  function_name = "api-handler"
  description   = "API request handler with VPC access"
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  s3_bucket     = "prod-deployments"
  s3_key        = "lambda/api-handler.zip"

  memory_size = 256
  timeout     = 60
  publish     = true

  environment_variables = {
    TABLE_NAME = "production-app-data"
    LOG_LEVEL  = "info"
  }

  vpc_subnet_ids         = ["subnet-abc123", "subnet-def456"]
  vpc_security_group_ids = ["sg-abc123"]

  reserved_concurrent_executions = 100
  log_retention_days             = 30

  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess",
  ]

  tags = {
    Project    = "production-app"
    CostCenter = "engineering"
  }
}

output "function_arn" {
  value = module.lambda.function_arn
}

output "function_invoke_arn" {
  value = module.lambda.function_invoke_arn
}

output "role_arn" {
  value = module.lambda.role_arn
}
