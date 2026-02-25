provider "aws" {
  region = "us-east-1"
}

module "api_gateway" {
  source = "../../"

  name        = "production-app"
  environment = "prod"
  api_name    = "main-api"
  description = "Production API with auth and rate limiting"

  resources = {
    users = {
      path_part = "users"
      methods = {
        get = {
          http_method     = "GET"
          authorization   = "COGNITO_USER_POOLS"
          authorizer_key  = "cognito"
          integration_uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789:function:get-users/invocations"
        }
        post = {
          http_method     = "POST"
          authorization   = "COGNITO_USER_POOLS"
          authorizer_key  = "cognito"
          integration_uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789:function:create-user/invocations"
        }
      }
    }
    health = {
      path_part = "health"
      methods = {
        get = {
          http_method     = "GET"
          integration_uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789:function:health-check/invocations"
        }
      }
    }
  }

  authorizers = {
    cognito = {
      type          = "COGNITO_USER_POOLS"
      provider_arns = ["arn:aws:cognito-idp:us-east-1:123456789:userpool/us-east-1_abc123"]
    }
  }

  enable_cors = true

  enable_api_key = true
  usage_plan = {
    name                 = "standard"
    throttle_burst_limit = 200
    throttle_rate_limit  = 100
    quota_limit          = 50000
    quota_period         = "MONTH"
  }

  tags = {
    Project    = "production-app"
    CostCenter = "engineering"
  }
}

output "invoke_url" {
  value = module.api_gateway.invoke_url
}

output "execution_arn" {
  value = module.api_gateway.execution_arn
}

output "api_key_value" {
  value     = module.api_gateway.api_key_value
  sensitive = true
}
