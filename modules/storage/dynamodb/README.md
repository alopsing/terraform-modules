# DynamoDB Module

Terraform module for creating and managing AWS DynamoDB tables with support for indexes, autoscaling, encryption, and streams.

## Features

- Hash and range key configuration
- Global Secondary Indexes (GSI)
- Local Secondary Indexes (LSI)
- Application autoscaling for PROVISIONED tables
- Server-side encryption
- Point-in-time recovery
- TTL configuration
- DynamoDB Streams

## Usage

### Basic

```hcl
module "dynamodb_table" {
  source = "../../modules/storage/dynamodb"

  name        = "myapp"
  environment = "dev"
  table_name  = "myapp-users"
  hash_key    = "user_id"

  attributes = [
    { name = "user_id", type = "S" }
  ]
}
```

### With GSI and Streams

```hcl
module "dynamodb_table" {
  source = "../../modules/storage/dynamodb"

  name        = "myapp"
  environment = "prod"
  table_name  = "myapp-orders"
  hash_key    = "order_id"
  range_key   = "created_at"

  attributes = [
    { name = "order_id", type = "S" },
    { name = "created_at", type = "S" },
    { name = "customer_id", type = "S" }
  ]

  global_secondary_indexes = [
    {
      name            = "customer-index"
      hash_key        = "customer_id"
      range_key       = "created_at"
      projection_type = "ALL"
    }
  ]

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  ttl_attribute    = "expires_at"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name for module resources | string | - | yes |
| environment | Environment (dev/staging/prod) | string | - | yes |
| tags | Additional tags | map(string) | {} | no |
| table_name | DynamoDB table name | string | - | yes |
| billing_mode | PAY_PER_REQUEST or PROVISIONED | string | "PAY_PER_REQUEST" | no |
| hash_key | Hash (partition) key | string | - | yes |
| range_key | Range (sort) key | string | null | no |
| attributes | Attribute definitions | list(object) | - | yes |
| global_secondary_indexes | GSI definitions | list(object) | [] | no |
| local_secondary_indexes | LSI definitions | list(object) | [] | no |
| enable_encryption | Enable SSE | bool | true | no |
| enable_point_in_time_recovery | Enable PITR | bool | true | no |
| ttl_attribute | TTL attribute name | string | "" | no |
| stream_enabled | Enable streams | bool | false | no |
| stream_view_type | Stream view type | string | "NEW_AND_OLD_IMAGES" | no |
| read_capacity | Read capacity units | number | null | no |
| write_capacity | Write capacity units | number | null | no |
| autoscaling_enabled | Enable autoscaling | bool | false | no |
| autoscaling_min_read | Min read capacity | number | 5 | no |
| autoscaling_max_read | Max read capacity | number | 100 | no |
| autoscaling_min_write | Min write capacity | number | 5 | no |
| autoscaling_max_write | Max write capacity | number | 100 | no |
| autoscaling_target_percentage | Target utilization % | number | 70 | no |

## Outputs

| Name | Description |
|------|-------------|
| table_id | The ID of the DynamoDB table |
| table_arn | The ARN of the DynamoDB table |
| table_name | The name of the DynamoDB table |
| table_stream_arn | The ARN of the table stream |
