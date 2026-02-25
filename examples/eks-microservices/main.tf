################################################################################
# EKS Microservices Platform
#
# Architecture:
#   VPC with public/private subnets
#   EKS cluster with managed node groups
#   IAM roles for IRSA (IAM Roles for Service Accounts)
#
# Modules used: VPC, EKS, IAM
################################################################################

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

################################################################################
# Networking
################################################################################

module "vpc" {
  source = "../../modules/networking/vpc"

  name        = var.project_name
  environment = var.environment
  cidr_block  = "10.0.0.0/16"

  azs                  = var.azs
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = var.environment != "prod"

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.project_name}-${var.environment}" = "shared"
  })
}

################################################################################
# EKS Cluster
################################################################################

module "eks" {
  source = "../../modules/compute/eks"

  name         = var.project_name
  environment  = var.environment
  cluster_name = "${var.project_name}-${var.environment}"

  cluster_version = var.cluster_version
  subnet_ids      = module.vpc.private_subnet_ids
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    general = {
      instance_types = ["t3.medium"]
      desired_size   = var.environment == "prod" ? 3 : 2
      min_size       = var.environment == "prod" ? 3 : 1
      max_size       = var.environment == "prod" ? 10 : 5
      disk_size      = 50
      labels = {
        role = "general"
      }
      ami_type = "AL2_x86_64"
    }
  }

  enable_cluster_logging = var.environment == "prod"

  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = var.cluster_public_access_cidrs

  tags = var.tags
}

################################################################################
# IRSA Roles — IAM Roles for Service Accounts
################################################################################

module "irsa_roles" {
  source = "../../modules/security/iam"

  name        = "${var.project_name}-irsa"
  environment = var.environment

  roles = {
    app = {
      description = "IRSA role for application pods"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect = "Allow"
          Principal = {
            Federated = module.eks.oidc_provider_arn
          }
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "${module.eks.oidc_provider_url}:sub" = "system:serviceaccount:default:app-sa"
              "${module.eks.oidc_provider_url}:aud" = "sts.amazonaws.com"
            }
          }
        }]
      })
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
      ]
    }

    external_dns = {
      description = "IRSA role for ExternalDNS"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
          Effect = "Allow"
          Principal = {
            Federated = module.eks.oidc_provider_arn
          }
          Action = "sts:AssumeRoleWithWebIdentity"
          Condition = {
            StringEquals = {
              "${module.eks.oidc_provider_url}:sub" = "system:serviceaccount:kube-system:external-dns"
              "${module.eks.oidc_provider_url}:aud" = "sts.amazonaws.com"
            }
          }
        }]
      })
      inline_policies = {
        route53 = {
          policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
              {
                Action   = ["route53:ChangeResourceRecordSets"]
                Effect   = "Allow"
                Resource = "arn:aws:route53:::hostedzone/*"
              },
              {
                Action   = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
                Effect   = "Allow"
                Resource = "*"
              },
            ]
          })
        }
      }
    }
  }

  tags = var.tags
}
