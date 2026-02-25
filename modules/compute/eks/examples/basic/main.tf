provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source = "../../"

  name         = "my-platform"
  environment  = "dev"
  cluster_name = "my-dev-cluster"
  subnet_ids   = ["subnet-111", "subnet-222", "subnet-333"]
  vpc_id       = "vpc-12345678"

  node_groups = {
    general = {
      instance_types = ["t3.medium"]
      desired_size   = 2
      min_size       = 1
      max_size       = 3
    }
  }

  tags = {
    Project = "example"
  }
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
