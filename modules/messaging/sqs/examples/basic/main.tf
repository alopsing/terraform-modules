provider "aws" {
  region = "us-east-1"
}

module "sqs" {
  source = "../../"

  name        = "my-app"
  environment = "dev"
  queue_name  = "my-queue"

  tags = {
    Team = "platform"
  }
}

output "queue_url" {
  value = module.sqs.queue_url
}

output "queue_arn" {
  value = module.sqs.queue_arn
}
