output "api_invoke_url" {
  description = "API Gateway invoke URL"
  value       = module.api_gateway.invoke_url
}

output "api_id" {
  description = "API Gateway ID"
  value       = module.api_gateway.api_id
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.api_handler.function_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}

output "deployment_bucket" {
  description = "S3 deployment bucket"
  value       = module.deployment_bucket.bucket_id
}
