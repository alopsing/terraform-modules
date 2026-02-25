provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

provider "tls" {}

variables {
  name            = "test-platform"
  environment     = "dev"
  cluster_name    = "test-cluster"
  cluster_version = "1.29"
  subnet_ids      = ["subnet-111", "subnet-222", "subnet-333"]
  vpc_id          = "vpc-12345678"
}

run "creates_eks_cluster" {
  command = plan

  assert {
    condition     = aws_eks_cluster.this.name == "test-cluster"
    error_message = "EKS cluster name should match the provided cluster_name."
  }

  assert {
    condition     = aws_eks_cluster.this.version == "1.29"
    error_message = "EKS cluster version should be 1.29."
  }
}

run "creates_cluster_iam_role" {
  command = plan

  assert {
    condition     = aws_iam_role.cluster.name == "test-platform-dev-eks-cluster-role"
    error_message = "Cluster IAM role name should follow naming convention."
  }
}

run "creates_node_groups" {
  command = plan

  variables {
    node_groups = {
      general = {
        instance_types = ["t3.medium"]
        desired_size   = 2
        min_size       = 1
        max_size       = 4
      }
    }
  }

  assert {
    condition     = length(aws_eks_node_group.this) == 1
    error_message = "Expected 1 node group to be created."
  }
}

run "creates_addons" {
  command = plan

  variables {
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
  }

  assert {
    condition     = length(aws_eks_addon.this) == 3
    error_message = "Expected 3 add-ons to be created."
  }
}

run "creates_oidc_provider" {
  command = plan

  assert {
    condition     = aws_iam_openid_connect_provider.cluster.client_id_list == toset(["sts.amazonaws.com"])
    error_message = "OIDC provider should have sts.amazonaws.com as client ID."
  }
}

run "creates_cloudwatch_log_group" {
  command = plan

  variables {
    enable_cluster_logging = true
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.cluster) == 1
    error_message = "CloudWatch log group should be created when logging is enabled."
  }
}
