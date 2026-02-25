provider "aws" {
  region = "us-east-1"
}

###############################################################################
# Supporting resources
###############################################################################

resource "aws_kms_key" "sqs" {
  description             = "KMS key for SQS queue encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

###############################################################################
# SQS module — standard queue with DLQ and encryption
###############################################################################

module "sqs" {
  source = "../../"

  name        = "my-app"
  environment = "prod"
  queue_name  = "order-processing"

  visibility_timeout_seconds = 60
  message_retention_seconds  = 604800 # 7 days
  receive_wait_time_seconds  = 20     # long polling

  kms_master_key_id                 = aws_kms_key.sqs.arn
  kms_data_key_reuse_period_seconds = 600

  create_dlq            = true
  dlq_max_receive_count = 5

  tags = {
    Team    = "platform"
    Service = "orders"
  }
}

###############################################################################
# SQS module — FIFO queue
###############################################################################

module "sqs_fifo" {
  source = "../../"

  name                        = "my-app"
  environment                 = "prod"
  queue_name                  = "order-events"
  fifo_queue                  = true
  content_based_deduplication = true
  create_dlq                  = true

  tags = {
    Team = "platform"
  }
}

output "queue_url" {
  value = module.sqs.queue_url
}

output "dlq_url" {
  value = module.sqs.dlq_url
}

output "fifo_queue_url" {
  value = module.sqs_fifo.queue_url
}
