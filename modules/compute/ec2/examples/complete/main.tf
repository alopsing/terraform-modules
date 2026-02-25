provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source = "../../"

  name           = "web-server"
  environment    = "prod"
  instance_count = 3
  subnet_id      = "subnet-12345678"
  vpc_id         = "vpc-12345678"

  instance_type       = "t3.medium"
  associate_public_ip = false
  key_name            = "my-key-pair"

  root_volume_size      = 50
  root_volume_type      = "gp3"
  root_volume_encrypted = true

  additional_ebs_volumes = [
    {
      device_name = "/dev/xvdb"
      size        = 100
      type        = "gp3"
      encrypted   = true
    },
    {
      device_name = "/dev/xvdc"
      size        = 200
      type        = "gp3"
      encrypted   = true
    }
  ]

  ingress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS from anywhere"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "SSH from internal"
    }
  ]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
  EOF

  tags = {
    Project = "web-platform"
    Team    = "infrastructure"
  }
}

output "instance_ids" {
  value = module.ec2.instance_ids
}

output "private_ips" {
  value = module.ec2.private_ips
}

output "security_group_id" {
  value = module.ec2.security_group_id
}
