variable "name" {
  description = "Name for the DynamoDB module resources"
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

variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode for the table"
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "Billing mode must be one of: PAY_PER_REQUEST, PROVISIONED."
  }
}

variable "hash_key" {
  description = "Hash (partition) key for the table"
  type        = string
}

variable "range_key" {
  description = "Range (sort) key for the table"
  type        = string
  default     = null
}

variable "attributes" {
  description = "List of attribute definitions"
  type = list(object({
    name = string
    type = string
  }))
}

variable "global_secondary_indexes" {
  description = "List of global secondary indexes"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string
    non_key_attributes = optional(list(string), [])
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "List of local secondary indexes"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string), [])
  }))
  default = []
}

variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "ttl_attribute" {
  description = "Name of the TTL attribute"
  type        = string
  default     = ""
}

variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type when streams are enabled"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "read_capacity" {
  description = "Read capacity units (required for PROVISIONED billing)"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "Write capacity units (required for PROVISIONED billing)"
  type        = number
  default     = null
}

variable "autoscaling_enabled" {
  description = "Enable autoscaling for PROVISIONED tables"
  type        = bool
  default     = false
}

variable "autoscaling_min_read" {
  description = "Minimum read capacity for autoscaling"
  type        = number
  default     = 5
}

variable "autoscaling_max_read" {
  description = "Maximum read capacity for autoscaling"
  type        = number
  default     = 100
}

variable "autoscaling_min_write" {
  description = "Minimum write capacity for autoscaling"
  type        = number
  default     = 5
}

variable "autoscaling_max_write" {
  description = "Maximum write capacity for autoscaling"
  type        = number
  default     = 100
}

variable "autoscaling_target_percentage" {
  description = "Target utilization percentage for autoscaling"
  type        = number
  default     = 70
}
