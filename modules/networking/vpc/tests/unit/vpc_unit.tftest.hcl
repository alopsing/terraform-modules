provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"

  default_tags {
    tags = {
      Test = "vpc-module"
    }
  }
}

variables {
  name        = "test-vpc"
  environment = "dev"
  cidr_block  = "10.0.0.0/16"
  azs         = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
}

run "vpc_created_with_correct_cidr" {
  command = plan

  assert {
    condition     = aws_vpc.this.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR block should be 10.0.0.0/16"
  }

  assert {
    condition     = aws_vpc.this.enable_dns_hostnames == true
    error_message = "DNS hostnames should be enabled by default"
  }

  assert {
    condition     = aws_vpc.this.enable_dns_support == true
    error_message = "DNS support should be enabled by default"
  }
}

run "correct_number_of_public_subnets" {
  command = plan

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Should create 2 public subnets"
  }
}

run "correct_number_of_private_subnets" {
  command = plan

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "Should create 2 private subnets"
  }
}

run "nat_gateway_created_when_enabled" {
  command = plan

  variables {
    enable_nat_gateway = true
    single_nat_gateway = false
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 2
    error_message = "Should create one NAT gateway per AZ"
  }

  assert {
    condition     = length(aws_eip.nat) == 2
    error_message = "Should create one EIP per NAT gateway"
  }
}

run "single_nat_gateway" {
  command = plan

  variables {
    enable_nat_gateway = true
    single_nat_gateway = true
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 1
    error_message = "Should create only one NAT gateway when single_nat_gateway is true"
  }
}

run "no_nat_gateway_when_disabled" {
  command = plan

  variables {
    enable_nat_gateway = false
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 0
    error_message = "Should not create NAT gateway when disabled"
  }
}

run "flow_logs_created_when_enabled" {
  command = plan

  variables {
    enable_flow_logs = true
  }

  assert {
    condition     = length(aws_flow_log.this) == 1
    error_message = "Should create flow log when enabled"
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.flow_log) == 1
    error_message = "Should create CloudWatch log group for flow logs"
  }

  assert {
    condition     = length(aws_iam_role.flow_log) == 1
    error_message = "Should create IAM role for flow logs"
  }
}

run "no_flow_logs_when_disabled" {
  command = plan

  variables {
    enable_flow_logs = false
  }

  assert {
    condition     = length(aws_flow_log.this) == 0
    error_message = "Should not create flow log when disabled"
  }
}

run "tags_applied_correctly" {
  command = plan

  variables {
    tags = {
      Project = "test"
    }
  }

  assert {
    condition     = aws_vpc.this.tags["Environment"] == "dev"
    error_message = "VPC should have Environment tag"
  }

  assert {
    condition     = aws_vpc.this.tags["ManagedBy"] == "terraform"
    error_message = "VPC should have ManagedBy tag"
  }

  assert {
    condition     = aws_vpc.this.tags["Project"] == "test"
    error_message = "VPC should have custom Project tag"
  }
}
