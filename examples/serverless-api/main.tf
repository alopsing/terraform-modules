################################################################################
# Serverless API
#
# Architecture:
#   API Gateway -> Lambda -> DynamoDB
#   S3 for Lambda deployment packages
#   IAM for least-privilege execution roles
#
# Modules used: API Gateway, Lambda, DynamoDB, S3, IAM
################################################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

################################################################################
# Data Store — DynamoDB
################################################################################

module "dynamodb" {
  source = "../../modules/storage/dynamodb"

  name        = var.project_name
  environment = var.environment
  table_name  = "${var.project_name}-items"

  hash_key  = "pk"
  range_key = "sk"

  attributes = [
    { name = "pk", type = "S" },
    { name = "sk", type = "S" },
    { name = "gsi1pk", type = "S" },
    { name = "gsi1sk", type = "S" },
  ]

  global_secondary_indexes = [
    {
      name            = "GSI1"
      hash_key        = "gsi1pk"
      range_key       = "gsi1sk"
      projection_type = "ALL"
    },
  ]

  enable_encryption             = true
  enable_point_in_time_recovery = true

  tags = var.tags
}

################################################################################
# Deployment Bucket — S3
################################################################################

module "deployment_bucket" {
  source = "../../modules/storage/s3"

  name        = var.project_name
  environment = var.environment
  bucket_name = "${var.project_name}-${var.environment}-deployments"

  enable_versioning = true
  encryption_type   = "SSE-S3"

  lifecycle_rules = [
    {
      id              = "cleanup-old-versions"
      enabled         = true
      prefix          = "lambda/"
      expiration_days = 90
      transitions     = []
    },
  ]

  tags = var.tags
}

################################################################################
# IAM — Additional Policies
################################################################################

module "iam" {
  source = "../../modules/security/iam"

  name        = var.project_name
  environment = var.environment

  policies = {
    dynamodb_access = {
      description = "DynamoDB access for Lambda functions"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "dynamodb:GetItem",
              "dynamodb:PutItem",
              "dynamodb:UpdateItem",
              "dynamodb:DeleteItem",
              "dynamodb:Query",
              "dynamodb:Scan",
            ]
            Effect   = "Allow"
            Resource = [module.dynamodb.table_arn, "${module.dynamodb.table_arn}/index/*"]
          },
        ]
      })
    }
  }

  tags = var.tags
}

################################################################################
# Lambda Functions
################################################################################

module "api_handler" {
  source = "../../modules/compute/lambda"

  name          = var.project_name
  environment   = var.environment
  function_name = "api-handler"
  description   = "Main API request handler"
  runtime       = "python3.12"
  handler       = "index.handler"

  s3_bucket = module.deployment_bucket.bucket_id
  s3_key    = "lambda/api-handler.zip"

  memory_size = 256
  timeout     = 30

  environment_variables = {
    TABLE_NAME  = module.dynamodb.table_name
    ENVIRONMENT = var.environment
  }

  additional_policy_arns = [module.iam.policy_arns["dynamodb_access"]]

  tags = var.tags
}

################################################################################
# API Gateway
################################################################################

module "api_gateway" {
  source = "../../modules/cdn/api-gateway"

  name        = var.project_name
  environment = var.environment
  api_name    = "${var.project_name}-api"
  description = "Serverless API for ${var.project_name}"

  resources = {
    items = {
      path_part = "items"
      methods = {
        get = {
          http_method     = "GET"
          integration_uri = module.api_handler.function_invoke_arn
        }
        post = {
          http_method     = "POST"
          integration_uri = module.api_handler.function_invoke_arn
        }
      }
    }
  }

  enable_cors = true

  tags = var.tags
}
