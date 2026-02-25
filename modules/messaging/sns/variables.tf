###############################################################################
# Common Variables
###############################################################################

variable "name" {
  description = "Name used for resource naming and tagging."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

###############################################################################
# SNS Topic Variables
###############################################################################

variable "topic_name" {
  description = "The name of the SNS topic. For FIFO topics, the '.fifo' suffix is appended automatically."
  type        = string
}

variable "display_name" {
  description = "The display name for the SNS topic."
  type        = string
  default     = ""
}

variable "fifo_topic" {
  description = "Whether to create a FIFO topic."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO topics."
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "The ARN of the KMS key for SNS topic encryption. Leave null to disable encryption."
  type        = string
  default     = null
}

variable "policy" {
  description = "Custom access policy JSON for the SNS topic. If not provided, no custom policy is applied."
  type        = string
  default     = null
}

variable "delivery_policy" {
  description = "The SNS delivery policy JSON."
  type        = string
  default     = null
}

variable "subscriptions" {
  description = "List of SNS topic subscriptions."
  type = list(object({
    protocol             = string
    endpoint             = string
    filter_policy        = optional(string, null)
    raw_message_delivery = optional(bool, false)
  }))
  default = []
}
