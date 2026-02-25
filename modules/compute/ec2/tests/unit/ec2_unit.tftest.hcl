mock_provider "aws" {}

variables {
  name        = "test-app"
  environment = "dev"
  subnet_id   = "subnet-12345678"
  vpc_id      = "vpc-12345678"
  ami_id      = "ami-12345678"
}

run "creates_ec2_instance" {
  command = plan

  assert {
    condition     = length(aws_instance.this) == 1
    error_message = "Expected 1 EC2 instance to be created."
  }

  assert {
    condition     = aws_instance.this[0].instance_type == "t3.micro"
    error_message = "Expected default instance type to be t3.micro."
  }

  assert {
    condition     = aws_instance.this[0].ami == "ami-12345678"
    error_message = "Expected AMI ID to match the provided value."
  }
}

run "creates_security_group" {
  command = plan

  assert {
    condition     = aws_security_group.this.vpc_id == "vpc-12345678"
    error_message = "Security group should be in the specified VPC."
  }

  assert {
    condition     = aws_security_group.this.name == "test-app-dev-sg"
    error_message = "Security group name should follow naming convention."
  }
}

run "creates_multiple_instances" {
  command = plan

  variables {
    instance_count = 3
  }

  assert {
    condition     = length(aws_instance.this) == 3
    error_message = "Expected 3 EC2 instances to be created."
  }
}

run "creates_ebs_volumes" {
  command = plan

  variables {
    additional_ebs_volumes = [
      {
        device_name = "/dev/xvdb"
        size        = 50
        type        = "gp3"
        encrypted   = true
      }
    ]
  }

  assert {
    condition     = length(aws_ebs_volume.this) == 1
    error_message = "Expected 1 additional EBS volume to be created."
  }

  assert {
    condition     = aws_ebs_volume.this[0].size == 50
    error_message = "EBS volume size should be 50 GB."
  }

  assert {
    condition     = aws_ebs_volume.this[0].encrypted == true
    error_message = "EBS volume should be encrypted."
  }
}
