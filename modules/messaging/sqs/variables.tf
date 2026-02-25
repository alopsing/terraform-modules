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
# SQS Queue Variables
###############################################################################

variable "queue_name" {
  description = "The name of the SQS queue. For FIFO queues, the '.fifo' suffix is appended automatically."
  type        = string
}

variable "fifo_queue" {
  description = "Whether to create a FIFO queue."
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO queues."
  type        = bool
  default     = false
}

variable "visibility_timeout_seconds" {
  description = "The visibility timeout for the queue in seconds."
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "The number of seconds to retain a message (default 4 days)."
  type        = number
  default     = 345600
}

variable "max_message_size" {
  description = "The maximum message size in bytes (default 256 KB)."
  type        = number
  default     = 262144
}

variable "delay_seconds" {
  description = "The delay in seconds before messages become available."
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "The time for which a ReceiveMessage call will wait for a message to arrive (long polling)."
  type        = number
  default     = 0
}

variable "kms_master_key_id" {
  description = "The ARN of the KMS key for SQS queue encryption. Leave null to disable encryption."
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "The length of time in seconds for which SQS can reuse a data key."
  type        = number
  default     = 300
}

###############################################################################
# Dead-Letter Queue Variables
###############################################################################

variable "create_dlq" {
  description = "Whether to create a dead-letter queue."
  type        = bool
  default     = false
}

variable "dlq_max_receive_count" {
  description = "The number of times a message can be received before being sent to the DLQ."
  type        = number
  default     = 3
}

variable "dlq_message_retention_seconds" {
  description = "The number of seconds to retain messages in the DLQ (default 14 days)."
  type        = number
  default     = 1209600
}

###############################################################################
# Queue Policy
###############################################################################

variable "policy" {
  description = "Custom access policy JSON for the SQS queue. If not provided, no custom policy is applied."
  type        = string
  default     = null
}
