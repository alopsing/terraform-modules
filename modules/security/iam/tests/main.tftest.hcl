provider "aws" {
  region = "us-east-1"
}

variables {
  name        = "test-iam"
  environment = "dev"
}

run "role_created_with_correct_name" {
  command = plan

  variables {
    roles = {
      app = {
        description = "Application role"
        assume_role_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [{
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = { Service = "ec2.amazonaws.com" }
          }]
        })
      }
    }
  }

  assert {
    condition     = aws_iam_role.this["app"].name == "test-iam-dev-app"
    error_message = "Role name should follow naming convention"
  }

  assert {
    condition     = aws_iam_role.this["app"].description == "Application role"
    error_message = "Role description should be set"
  }
}

run "instance_profile_created_when_enabled" {
  command = plan

  variables {
    roles = {
      ec2 = {
        assume_role_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [{
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = { Service = "ec2.amazonaws.com" }
          }]
        })
        create_instance_profile = true
      }
    }
  }

  assert {
    condition     = aws_iam_instance_profile.this["ec2"].name == "test-iam-dev-ec2"
    error_message = "Instance profile should be created"
  }
}

run "no_instance_profile_when_disabled" {
  command = plan

  variables {
    roles = {
      lambda = {
        assume_role_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [{
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = { Service = "lambda.amazonaws.com" }
          }]
        })
        create_instance_profile = false
      }
    }
  }

  assert {
    condition     = length(aws_iam_instance_profile.this) == 0
    error_message = "Instance profile should not be created when disabled"
  }
}

run "policy_created_with_correct_name" {
  command = plan

  variables {
    policies = {
      s3_read = {
        description = "S3 read-only access"
        policy = jsonencode({
          Version = "2012-10-17"
          Statement = [{
            Action   = ["s3:GetObject", "s3:ListBucket"]
            Effect   = "Allow"
            Resource = "*"
          }]
        })
      }
    }
  }

  assert {
    condition     = aws_iam_policy.this["s3_read"].name == "test-iam-dev-s3_read"
    error_message = "Policy name should follow naming convention"
  }
}

run "tags_applied_correctly" {
  command = plan

  variables {
    roles = {
      test = {
        assume_role_policy = jsonencode({
          Version = "2012-10-17"
          Statement = [{
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = { Service = "ec2.amazonaws.com" }
          }]
        })
      }
    }
    tags = { Project = "test" }
  }

  assert {
    condition     = aws_iam_role.this["test"].tags["Environment"] == "dev"
    error_message = "Should have Environment tag"
  }

  assert {
    condition     = aws_iam_role.this["test"].tags["Project"] == "test"
    error_message = "Should have custom Project tag"
  }
}
