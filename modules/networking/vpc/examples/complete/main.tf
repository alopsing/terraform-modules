provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../"

  name        = "production-app"
  environment = "prod"
  cidr_block  = "10.0.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_logs          = true
  flow_log_destination_type = "cloud-watch-logs"

  tags = {
    Project    = "production-app"
    CostCenter = "engineering"
    Compliance = "soc2"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  value = module.vpc.nat_gateway_ids
}

output "igw_id" {
  value = module.vpc.igw_id
}
