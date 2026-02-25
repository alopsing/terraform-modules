# AWS SQS Terraform Module

This module creates and manages AWS SQS queues with support for FIFO queues, dead-letter queues, encryption, and custom access policies.

## Features

- Standard and FIFO SQS queues
- Dead-letter queue (DLQ) with configurable redrive policy
- Server-side encryption with KMS
- Configurable visibility timeout, message retention, and long polling
- Custom access policies

## Usage

### Basic

```hcl
module "sqs" {
  source = "path/to/modules/messaging/sqs"

  name        = "my-app"
  environment = "dev"
  queue_name  = "my-queue"
}
```

### With Dead-Letter Queue and Encryption

```hcl
module "sqs" {
  source = "path/to/modules/messaging/sqs"

  name        = "my-app"
  environment = "prod"
  queue_name  = "order-processing"

  visibility_timeout_seconds = 60
  message_retention_seconds  = 604800
  receive_wait_time_seconds  = 20

  kms_master_key_id = aws_kms_key.sqs.arn

  create_dlq            = true
  dlq_max_receive_count = 5

  tags = {
    Team = "platform"
  }
}
```

### FIFO Queue

```hcl
module "sqs_fifo" {
  source = "path/to/modules/messaging/sqs"

  name                        = "my-app"
  environment                 = "prod"
  queue_name                  = "order-events"
  fifo_queue                  = true
  content_based_deduplication = true
  create_dlq                  = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name used for resource naming and tagging | `string` | n/a | yes |
| environment | Deployment environment (dev, staging, prod) | `string` | n/a | yes |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| queue_name | The name of the SQS queue | `string` | n/a | yes |
| fifo_queue | Whether to create a FIFO queue | `bool` | `false` | no |
| content_based_deduplication | Enable content-based deduplication for FIFO queues | `bool` | `false` | no |
| visibility_timeout_seconds | Visibility timeout in seconds | `number` | `30` | no |
| message_retention_seconds | Message retention period in seconds | `number` | `345600` | no |
| max_message_size | Maximum message size in bytes | `number` | `262144` | no |
| delay_seconds | Delay before messages become available | `number` | `0` | no |
| receive_wait_time_seconds | Long polling wait time in seconds | `number` | `0` | no |
| kms_master_key_id | ARN of the KMS key for encryption | `string` | `null` | no |
| kms_data_key_reuse_period_seconds | KMS data key reuse period in seconds | `number` | `300` | no |
| create_dlq | Whether to create a dead-letter queue | `bool` | `false` | no |
| dlq_max_receive_count | Max receives before sending to DLQ | `number` | `3` | no |
| dlq_message_retention_seconds | DLQ message retention in seconds | `number` | `1209600` | no |
| policy | Custom access policy JSON for the queue | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| queue_id | The ID of the SQS queue |
| queue_arn | The ARN of the SQS queue |
| queue_url | The URL of the SQS queue |
| queue_name | The name of the SQS queue |
| dlq_id | The ID of the dead-letter queue (null if not created) |
| dlq_arn | The ARN of the dead-letter queue (null if not created) |
| dlq_url | The URL of the dead-letter queue (null if not created) |
