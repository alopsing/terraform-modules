provider "aws" {
  region = "us-east-1"
}

module "api_gateway" {
  source = "../../"

  name        = "my-app"
  environment = "dev"
  api_name    = "my-api"
  description = "My application API"

  resources = {
    users = {
      path_part = "users"
      methods = {
        get = {
          http_method     = "GET"
          integration_uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789:function:get-users/invocations"
        }
      }
    }
  }

  tags = {
    Project = "my-app"
  }
}

output "invoke_url" {
  value = module.api_gateway.invoke_url
}

output "api_id" {
  value = module.api_gateway.api_id
}
