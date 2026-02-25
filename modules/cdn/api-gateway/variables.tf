variable "name" {
  description = "Name prefix for resources"
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

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "description" {
  description = "Description of the API"
  type        = string
  default     = ""
}

variable "stage_name" {
  description = "Name of the deployment stage"
  type        = string
  default     = "v1"
}

variable "stage_description" {
  description = "Description of the stage"
  type        = string
  default     = ""
}

variable "endpoint_type" {
  description = "Endpoint type (EDGE, REGIONAL, PRIVATE)"
  type        = string
  default     = "REGIONAL"

  validation {
    condition     = contains(["EDGE", "REGIONAL", "PRIVATE"], var.endpoint_type)
    error_message = "Endpoint type must be EDGE, REGIONAL, or PRIVATE."
  }
}

variable "resources" {
  description = "Map of API resources and their methods"
  type = map(object({
    path_part = string
    methods = map(object({
      http_method      = string
      authorization    = optional(string, "NONE")
      authorizer_key   = optional(string, null)
      integration_type = optional(string, "AWS_PROXY")
      integration_uri  = string
    }))
  }))
  default = {}
}

variable "authorizers" {
  description = "Map of API Gateway authorizers"
  type = map(object({
    type            = string
    provider_arns   = optional(list(string), [])
    authorizer_uri  = optional(string, null)
    identity_source = optional(string, "method.request.header.Authorization")
  }))
  default = {}
}

variable "enable_api_key" {
  description = "Enable API key requirement"
  type        = bool
  default     = false
}

variable "api_key_name" {
  description = "Name for the API key"
  type        = string
  default     = ""
}

variable "usage_plan" {
  description = "Usage plan configuration"
  type = object({
    name                 = string
    throttle_burst_limit = optional(number, 100)
    throttle_rate_limit  = optional(number, 50)
    quota_limit          = optional(number, 10000)
    quota_period         = optional(string, "MONTH")
  })
  default = null
}

variable "enable_cors" {
  description = "Enable CORS support"
  type        = bool
  default     = false
}

variable "cors_allow_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_methods" {
  description = "Allowed methods for CORS"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

variable "cors_allow_headers" {
  description = "Allowed headers for CORS"
  type        = list(string)
  default     = ["Content-Type", "Authorization"]
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
