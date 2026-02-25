provider "aws" {
  region = "us-east-1"
}

module "iam" {
  source = "../../"

  name        = "my-app"
  environment = "dev"

  roles = {
    app = {
      description = "Application EC2 role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Action    = "sts:AssumeRole"
          Effect    = "Allow"
          Principal = { Service = "ec2.amazonaws.com" }
        }]
      })
      create_instance_profile = true
      managed_policy_arns     = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
    }
  }

  tags = {
    Project = "my-app"
  }
}

output "role_arns" {
  value = module.iam.role_arns
}

output "instance_profile_arns" {
  value = module.iam.instance_profile_arns
}
