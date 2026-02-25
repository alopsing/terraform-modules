provider "aws" {
  region = "us-east-1"
}

module "sns" {
  source = "../../"

  name        = "my-app"
  environment = "dev"
  topic_name  = "my-notifications"

  tags = {
    Team = "platform"
  }
}

output "topic_arn" {
  value = module.sns.topic_arn
}
