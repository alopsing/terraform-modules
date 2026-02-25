variable "name" {
  description = "Name prefix for IAM resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "roles" {
  description = "Map of IAM roles to create"
  type = map(object({
    description          = optional(string, "")
    assume_role_policy   = string
    max_session_duration = optional(number, 3600)
    managed_policy_arns  = optional(list(string), [])
    inline_policies = optional(map(object({
      policy = string
    })), {})
    create_instance_profile = optional(bool, false)
  }))
  default = {}
}

variable "policies" {
  description = "Map of IAM policies to create"
  type = map(object({
    description = optional(string, "")
    policy      = string
    path        = optional(string, "/")
  }))
  default = {}
}

variable "oidc_providers" {
  description = "Map of OIDC providers to create"
  type = map(object({
    url             = string
    client_id_list  = list(string)
    thumbprint_list = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
