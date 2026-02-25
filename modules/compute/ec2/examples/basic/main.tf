provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source = "../../"

  name        = "my-app"
  environment = "dev"
  subnet_id   = "subnet-12345678"
  vpc_id      = "vpc-12345678"

  instance_type = "t3.micro"

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "SSH access from internal network"
    }
  ]

  tags = {
    Project = "example"
  }
}

output "instance_ids" {
  value = module.ec2.instance_ids
}
