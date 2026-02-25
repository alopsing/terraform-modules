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
# Test: Basic SNS topic creation
###############################################################################

run "basic_topic_creation" {
  command = plan

  variables {
    name        = "test"
    environment = "dev"
    topic_name  = "test-topic"
  }

  assert {
    condition     = aws_sns_topic.this.name == "test-topic"
    error_message = "Topic name should be 'test-topic'."
  }

  assert {
    condition     = aws_sns_topic.this.fifo_topic == false
    error_message = "Topic should not be FIFO by default."
  }
}

###############################################################################
# Test: FIFO topic
###############################################################################

run "fifo_topic" {
  command = plan

  variables {
    name                        = "test"
    environment                 = "dev"
    topic_name                  = "test-topic"
    fifo_topic                  = true
    content_based_deduplication = true
  }

  assert {
    condition     = aws_sns_topic.this.name == "test-topic.fifo"
    error_message = "FIFO topic name should end with '.fifo'."
  }

  assert {
    condition     = aws_sns_topic.this.fifo_topic == true
    error_message = "Topic should be FIFO."
  }

  assert {
    condition     = aws_sns_topic.this.content_based_deduplication == true
    error_message = "Content-based deduplication should be enabled."
  }
}

###############################################################################
# Test: Encrypted topic
###############################################################################

run "encrypted_topic" {
  command = plan

  variables {
    name              = "test"
    environment       = "prod"
    topic_name        = "encrypted-topic"
    kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/test-key-id"
  }

  assert {
    condition     = aws_sns_topic.this.kms_master_key_id == "arn:aws:kms:us-east-1:123456789012:key/test-key-id"
    error_message = "KMS key ID should be set."
  }
}

###############################################################################
# Test: Subscriptions
###############################################################################

run "topic_with_subscriptions" {
  command = plan

  variables {
    name        = "test"
    environment = "dev"
    topic_name  = "sub-topic"
    subscriptions = [
      {
        protocol = "email"
        endpoint = "test@example.com"
      },
      {
        protocol             = "sqs"
        endpoint             = "arn:aws:sqs:us-east-1:123456789012:test-queue"
        raw_message_delivery = true
      },
    ]
  }

  assert {
    condition     = length(aws_sns_topic_subscription.this) == 2
    error_message = "Should create 2 subscriptions."
  }
}
