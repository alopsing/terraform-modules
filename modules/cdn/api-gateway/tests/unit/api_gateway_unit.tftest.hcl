provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

variables {
  name        = "test"
  environment = "dev"
  api_name    = "my-api"
  description = "Test API"
  stage_name  = "v1"

  resources = {
    users = {
      path_part = "users"
      methods = {
        get = {
          http_method     = "GET"
          integration_uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789:function:my-func/invocations"
        }
      }
    }
  }
}

run "api_created_with_correct_name" {
  command = plan

  assert {
    condition     = aws_api_gateway_rest_api.this.name == "test-dev-my-api"
    error_message = "API name should follow naming convention"
  }

  assert {
    condition     = aws_api_gateway_rest_api.this.description == "Test API"
    error_message = "API description should be set"
  }
}

run "stage_created" {
  command = plan

  assert {
    condition     = aws_api_gateway_stage.this.stage_name == "v1"
    error_message = "Stage name should be v1"
  }
}

run "resource_created" {
  command = plan

  assert {
    condition     = aws_api_gateway_resource.this["users"].path_part == "users"
    error_message = "Resource path should be users"
  }
}

run "no_api_key_by_default" {
  command = plan

  assert {
    condition     = length(aws_api_gateway_api_key.this) == 0
    error_message = "API key should not be created by default"
  }
}

run "api_key_when_enabled" {
  command = plan

  variables {
    enable_api_key = true
  }

  assert {
    condition     = length(aws_api_gateway_api_key.this) == 1
    error_message = "API key should be created when enabled"
  }
}

run "tags_applied_correctly" {
  command = plan

  variables {
    tags = { Project = "test" }
  }

  assert {
    condition     = aws_api_gateway_rest_api.this.tags["Environment"] == "dev"
    error_message = "Should have Environment tag"
  }

  assert {
    condition     = aws_api_gateway_rest_api.this.tags["Project"] == "test"
    error_message = "Should have custom Project tag"
  }
}
