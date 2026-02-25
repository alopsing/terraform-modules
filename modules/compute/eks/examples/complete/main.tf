provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source = "../../"

  name            = "platform"
  environment     = "prod"
  cluster_name    = "prod-cluster"
  cluster_version = "1.29"
  subnet_ids      = ["subnet-111", "subnet-222", "subnet-333"]
  vpc_id          = "vpc-12345678"

  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = ["10.0.0.0/8"]

  enable_cluster_logging = true
  cluster_log_types      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  node_groups = {
    general = {
      instance_types = ["t3.large"]
      desired_size   = 3
      min_size       = 2
      max_size       = 6
      disk_size      = 100
      labels = {
        workload = "general"
      }
    }
    compute = {
      instance_types = ["c5.2xlarge"]
      desired_size   = 2
      min_size       = 1
      max_size       = 10
      disk_size      = 100
      ami_type       = "AL2_x86_64"
      labels = {
        workload = "compute-intensive"
      }
    }
  }

  cluster_addons = {
    vpc-cni = {
      addon_version = null
    }
    coredns = {
      addon_version = null
    }
    kube-proxy = {
      addon_version = null
    }
  }

  tags = {
    Project = "platform"
    Team    = "infrastructure"
  }
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "node_group_arns" {
  value = module.eks.node_group_arns
}
