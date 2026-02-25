# AWS SNS Terraform Module

This module creates and manages AWS SNS topics with support for subscriptions, encryption, FIFO topics, and custom access policies.

## Features

- Standard and FIFO SNS topics
- Server-side encryption with KMS
- Multiple subscription types (email, SQS, Lambda, HTTP/S)
- Subscription filter policies
- Raw message delivery
- Custom access policies
- Delivery policies

## Usage

### Basic

```hcl
module "sns" {
  source = "path/to/modules/messaging/sns"

  name        = "my-app"
  environment = "dev"
  topic_name  = "my-notifications"
}
```

### With Subscriptions and Encryption

```hcl
module "sns" {
  source = "path/to/modules/messaging/sns"

  name              = "my-app"
  environment       = "prod"
  topic_name        = "order-events"
  display_name      = "Order Events"
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
        event_type = ["order_created"]
      })
    },
  ]

  tags = {
    Team = "platform"
  }
}
```

### FIFO Topic

```hcl
module "sns_fifo" {
  source = "path/to/modules/messaging/sns"

  name                        = "my-app"
  environment                 = "prod"
  topic_name                  = "order-events"
  fifo_topic                  = true
  content_based_deduplication = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name used for resource naming and tagging | `string` | n/a | yes |
| environment | Deployment environment (dev, staging, prod) | `string` | n/a | yes |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| topic_name | The name of the SNS topic | `string` | n/a | yes |
| display_name | The display name for the SNS topic | `string` | `""` | no |
| fifo_topic | Whether to create a FIFO topic | `bool` | `false` | no |
| content_based_deduplication | Enable content-based deduplication for FIFO topics | `bool` | `false` | no |
| kms_master_key_id | ARN of the KMS key for encryption | `string` | `null` | no |
| policy | Custom access policy JSON for the topic | `string` | `null` | no |
| delivery_policy | The SNS delivery policy JSON | `string` | `null` | no |
| subscriptions | List of topic subscriptions | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| topic_arn | The ARN of the SNS topic |
| topic_id | The ID of the SNS topic |
| topic_name | The name of the SNS topic |
| subscription_arns | List of ARNs for the SNS topic subscriptions |
