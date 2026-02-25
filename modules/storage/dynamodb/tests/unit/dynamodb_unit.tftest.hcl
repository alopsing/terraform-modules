mock_provider "aws" {}

variables {
  name        = "test"
  environment = "dev"
  table_name  = "test-table"
  hash_key    = "pk"
  attributes = [
    { name = "pk", type = "S" }
  ]
}

run "table_creation" {
  command = plan

  assert {
    condition     = aws_dynamodb_table.this.name == "test-table"
    error_message = "Table name does not match expected value."
  }

  assert {
    condition     = aws_dynamodb_table.this.billing_mode == "PAY_PER_REQUEST"
    error_message = "Default billing mode should be PAY_PER_REQUEST."
  }

  assert {
    condition     = aws_dynamodb_table.this.hash_key == "pk"
    error_message = "Hash key does not match expected value."
  }
}

run "encryption_enabled" {
  command = plan

  assert {
    condition     = aws_dynamodb_table.this.server_side_encryption[0].enabled == true
    error_message = "Server-side encryption should be enabled by default."
  }
}

run "pitr_enabled" {
  command = plan

  assert {
    condition     = aws_dynamodb_table.this.point_in_time_recovery[0].enabled == true
    error_message = "Point-in-time recovery should be enabled by default."
  }
}

run "ttl_configuration" {
  command = plan

  variables {
    ttl_attribute = "expires_at"
  }

  assert {
    condition     = aws_dynamodb_table.this.ttl[0].attribute_name == "expires_at"
    error_message = "TTL attribute should be set to expires_at."
  }

  assert {
    condition     = aws_dynamodb_table.this.ttl[0].enabled == true
    error_message = "TTL should be enabled when attribute is set."
  }
}

run "streams_configuration" {
  command = plan

  variables {
    stream_enabled   = true
    stream_view_type = "NEW_AND_OLD_IMAGES"
  }

  assert {
    condition     = aws_dynamodb_table.this.stream_enabled == true
    error_message = "Streams should be enabled."
  }

  assert {
    condition     = aws_dynamodb_table.this.stream_view_type == "NEW_AND_OLD_IMAGES"
    error_message = "Stream view type should be NEW_AND_OLD_IMAGES."
  }
}
