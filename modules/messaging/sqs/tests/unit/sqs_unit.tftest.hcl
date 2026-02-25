###############################################################################
# Provider for tests
###############################################################################

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

###############################################################################
# Test: Basic SQS queue creation
###############################################################################

run "basic_queue_creation" {
  command = plan

  variables {
    name        = "test"
    environment = "dev"
    queue_name  = "test-queue"
  }

  assert {
    condition     = aws_sqs_queue.this.name == "test-queue"
    error_message = "Queue name should be 'test-queue'."
  }

  assert {
    condition     = aws_sqs_queue.this.fifo_queue == false
    error_message = "Queue should not be FIFO by default."
  }

  assert {
    condition     = aws_sqs_queue.this.visibility_timeout_seconds == 30
    error_message = "Default visibility timeout should be 30 seconds."
  }

  assert {
    condition     = aws_sqs_queue.this.message_retention_seconds == 345600
    error_message = "Default message retention should be 345600 seconds (4 days)."
  }
}

###############################################################################
# Test: FIFO queue
###############################################################################

run "fifo_queue" {
  command = plan

  variables {
    name                        = "test"
    environment                 = "dev"
    queue_name                  = "test-queue"
    fifo_queue                  = true
    content_based_deduplication = true
  }

  assert {
    condition     = aws_sqs_queue.this.name == "test-queue.fifo"
    error_message = "FIFO queue name should end with '.fifo'."
  }

  assert {
    condition     = aws_sqs_queue.this.fifo_queue == true
    error_message = "Queue should be FIFO."
  }

  assert {
    condition     = aws_sqs_queue.this.content_based_deduplication == true
    error_message = "Content-based deduplication should be enabled."
  }
}

###############################################################################
# Test: Queue with DLQ
###############################################################################

run "queue_with_dlq" {
  command = plan

  variables {
    name                  = "test"
    environment           = "dev"
    queue_name            = "test-queue"
    create_dlq            = true
    dlq_max_receive_count = 5
  }

  assert {
    condition     = length(aws_sqs_queue.dlq) == 1
    error_message = "DLQ should be created when create_dlq is true."
  }

  assert {
    condition     = aws_sqs_queue.dlq[0].name == "test-queue-dlq"
    error_message = "DLQ name should be 'test-queue-dlq'."
  }
}

###############################################################################
# Test: Encrypted queue
###############################################################################

run "encrypted_queue" {
  command = plan

  variables {
    name              = "test"
    environment       = "prod"
    queue_name        = "encrypted-queue"
    kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/test-key-id"
  }

  assert {
    condition     = aws_sqs_queue.this.kms_master_key_id == "arn:aws:kms:us-east-1:123456789012:key/test-key-id"
    error_message = "KMS key ID should be set."
  }
}
