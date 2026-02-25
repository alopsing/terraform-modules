variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster and node groups"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "node_groups" {
  description = "Map of EKS managed node group configurations"
  type = map(object({
    instance_types = list(string)
    desired_size   = number
    min_size       = number
    max_size       = number
    disk_size      = optional(number, 50)
    labels         = optional(map(string), {})
    ami_type       = optional(string, "AL2_x86_64")
  }))
  default = {}
}

variable "cluster_addons" {
  description = "Map of EKS cluster add-on configurations"
  type = map(object({
    addon_version = optional(string, null)
  }))
  default = {
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

variable "enable_cluster_logging" {
  description = "Whether to enable EKS cluster CloudWatch logging"
  type        = bool
  default     = true
}

variable "cluster_log_types" {
  description = "List of EKS cluster log types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator"]
}

variable "secrets_encryption_key_arn" {
  description = "ARN of the KMS key to encrypt Kubernetes secrets. If set, enables envelope encryption for secrets."
  type        = string
  default     = null
}

variable "endpoint_private_access" {
  description = "Whether the EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
