provider "aws" {
  region = "us-east-1"
}

module "lambda" {
  source = "../../"

  name          = "my-app"
  environment   = "dev"
  function_name = "hello-world"
  description   = "Simple hello world function"
  runtime       = "python3.12"
  handler       = "index.handler"
  s3_bucket     = "my-deployments"
  s3_key        = "lambda/hello-world.zip"

  tags = {
    Project = "my-app"
  }
}

output "function_arn" {
  value = module.lambda.function_arn
}

output "function_name" {
  value = module.lambda.function_name
}
