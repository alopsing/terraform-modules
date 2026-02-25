provider "aws" {
  region = "us-east-1"
}

###############################################################################
# Supporting resources
###############################################################################

resource "aws_kms_key" "sns" {
  description             = "KMS key for SNS topic encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_sqs_queue" "target" {
  name              = "my-app-target-queue"
  kms_master_key_id = aws_kms_key.sns.arn
}

###############################################################################
# SNS module — complete example
###############################################################################

module "sns" {
  source = "../../"

  name         = "my-app"
  environment  = "prod"
  topic_name   = "order-events"
  display_name = "Order Events"

  kms_master_key_id = aws_kms_key.sns.arn

  subscriptions = [
    {
      protocol = "email"
      endpoint = "alerts@example.com"
    },
    {
      protocol             = "sqs"
      endpoint             = aws_sqs_queue.target.arn
      raw_message_delivery = true
      filter_policy = jsonencode({
        event_type = ["order_created", "order_updated"]
      })
    },
  ]

  tags = {
    Team    = "platform"
    Service = "orders"
  }
}

###############################################################################
# FIFO topic example
###############################################################################

module "sns_fifo" {
  source = "../../"

  name                        = "my-app"
  environment                 = "prod"
  topic_name                  = "order-events-fifo"
  fifo_topic                  = true
  content_based_deduplication = true

  tags = {
    Team = "platform"
  }
}

output "topic_arn" {
  value = module.sns.topic_arn
}

output "fifo_topic_arn" {
  value = module.sns_fifo.topic_arn
}
