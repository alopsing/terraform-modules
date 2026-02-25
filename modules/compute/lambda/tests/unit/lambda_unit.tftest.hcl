provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

variables {
  name          = "test"
  environment   = "dev"
  function_name = "my-func"
  runtime       = "python3.12"
  handler       = "index.handler"
  filename      = null
  s3_bucket     = "my-deployments"
  s3_key        = "lambda/my-func.zip"
}

run "function_created_with_correct_config" {
  command = plan

  assert {
    condition     = aws_lambda_function.this.function_name == "test-dev-my-func"
    error_message = "Function name should follow naming convention"
  }

  assert {
    condition     = aws_lambda_function.this.runtime == "python3.12"
    error_message = "Runtime should be python3.12"
  }

  assert {
    condition     = aws_lambda_function.this.handler == "index.handler"
    error_message = "Handler should be index.handler"
  }

  assert {
    condition     = aws_lambda_function.this.memory_size == 128
    error_message = "Default memory should be 128 MB"
  }

  assert {
    condition     = aws_lambda_function.this.timeout == 30
    error_message = "Default timeout should be 30 seconds"
  }
}

run "iam_role_created" {
  command = plan

  assert {
    condition     = aws_iam_role.this.name == "test-dev-my-func-exec"
    error_message = "Execution role name should follow convention"
  }
}

run "log_group_created" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.this.name == "/aws/lambda/test-dev-my-func"
    error_message = "Log group should follow Lambda naming convention"
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.retention_in_days == 14
    error_message = "Default log retention should be 14 days"
  }
}

run "no_vpc_config_by_default" {
  command = plan

  assert {
    condition     = length(aws_iam_role_policy_attachment.vpc_access) == 0
    error_message = "VPC access policy should not be attached without VPC config"
  }
}

run "vpc_config_when_provided" {
  command = plan

  variables {
    vpc_subnet_ids         = ["subnet-abc123"]
    vpc_security_group_ids = ["sg-abc123"]
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.vpc_access) == 1
    error_message = "VPC access policy should be attached with VPC config"
  }
}

run "tags_applied_correctly" {
  command = plan

  variables {
    tags = { Project = "test" }
  }

  assert {
    condition     = aws_lambda_function.this.tags["Environment"] == "dev"
    error_message = "Should have Environment tag"
  }

  assert {
    condition     = aws_lambda_function.this.tags["Project"] == "test"
    error_message = "Should have custom Project tag"
  }
}
