###############################################################################
# SQS Queue (main)
###############################################################################

resource "aws_sqs_queue" "this" {
  name                              = var.fifo_queue ? "${var.queue_name}.fifo" : var.queue_name
  fifo_queue                        = var.fifo_queue
  content_based_deduplication       = var.fifo_queue ? var.content_based_deduplication : false
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  message_retention_seconds         = var.message_retention_seconds
  max_message_size                  = var.max_message_size
  delay_seconds                     = var.delay_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id != null ? var.kms_data_key_reuse_period_seconds : null

  tags = local.common_tags
}

###############################################################################
# Dead-Letter Queue (conditional)
###############################################################################

resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0

  name                              = var.fifo_queue ? "${var.queue_name}-dlq.fifo" : "${var.queue_name}-dlq"
  fifo_queue                        = var.fifo_queue
  content_based_deduplication       = var.fifo_queue ? var.content_based_deduplication : false
  message_retention_seconds         = var.dlq_message_retention_seconds
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id != null ? var.kms_data_key_reuse_period_seconds : null

  tags = merge(local.common_tags, {
    Purpose = "dead-letter-queue"
  })
}

###############################################################################
# Redrive Policy (conditional — only when DLQ is created)
###############################################################################

resource "aws_sqs_queue_redrive_policy" "this" {
  count = var.create_dlq ? 1 : 0

  queue_url = aws_sqs_queue.this.url
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.dlq_max_receive_count
  })
}

###############################################################################
# Queue Policy (conditional)
###############################################################################

resource "aws_sqs_queue_policy" "this" {
  count = var.policy != null ? 1 : 0

  queue_url = aws_sqs_queue.this.url
  policy    = var.policy
}
