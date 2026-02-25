provider "aws" {
  region = "us-east-1"
}

module "iam" {
  source = "../../"

  name        = "production-app"
  environment = "prod"

  roles = {
    ec2_app = {
      description = "EC2 application role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action    = "sts:AssumeRole"
          Effect    = "Allow"
          Principal = { Service = "ec2.amazonaws.com" }
        }]
      })
      create_instance_profile = true
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
      ]
      inline_policies = {
        s3_access = {
          policy = jsonencode({
            Version = "2012-10-17"
            Statement = [{
              Action   = ["s3:GetObject", "s3:PutObject"]
              Effect   = "Allow"
              Resource = "arn:aws:s3:::my-app-bucket/*"
            }]
          })
        }
      }
    }

    lambda_exec = {
      description = "Lambda execution role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action    = "sts:AssumeRole"
          Effect    = "Allow"
          Principal = { Service = "lambda.amazonaws.com" }
        }]
      })
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
      ]
    }
  }

  policies = {
    dynamodb_access = {
      description = "DynamoDB read/write access"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:Query",
            "dynamodb:Scan",
          ]
          Effect   = "Allow"
          Resource = "*"
        }]
      })
    }
  }

  tags = {
    Project    = "production-app"
    CostCenter = "engineering"
  }
}

output "role_arns" {
  value = module.iam.role_arns
}

output "policy_arns" {
  value = module.iam.policy_arns
}
