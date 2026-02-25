# AWS Lambda Module

Terraform module to create Lambda functions with IAM execution roles, CloudWatch log groups, optional VPC configuration, and event source mappings.

## Features

- Lambda function with configurable runtime, memory, and timeout
- Automatic IAM execution role creation
- CloudWatch log group with configurable retention
- Optional VPC configuration with automatic policy attachment
- Lambda layers support
- Event source mappings (SQS, DynamoDB Streams, Kinesis)
- Reserved concurrency configuration
- Consistent resource tagging

## Usage

### Basic

```hcl
module "lambda" {
  source = "../../modules/compute/lambda"

  name          = "my-app"
  environment   = "dev"
  function_name = "hello-world"
  runtime       = "python3.12"
  handler       = "index.handler"
  s3_bucket     = "my-deployments"
  s3_key        = "lambda/hello-world.zip"
}
```

### With VPC and Environment Variables

```hcl
module "lambda" {
  source = "../../modules/compute/lambda"

  name          = "my-app"
  environment   = "prod"
  function_name = "api-handler"
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  s3_bucket     = "prod-deployments"
  s3_key        = "lambda/api-handler.zip"
  memory_size   = 256
  timeout       = 60

  environment_variables = {
    TABLE_NAME = "my-table"
  }

  vpc_subnet_ids         = ["subnet-abc", "subnet-def"]
  vpc_security_group_ids = ["sg-abc"]
}
```

## Examples

- [Basic](examples/basic/) — Simple Lambda function
- [Complete](examples/complete/) — Lambda with VPC, env vars, and additional policies

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for resources | `string` | n/a | yes |
| environment | Environment name (dev, staging, prod) | `string` | n/a | yes |
| function\_name | Name of the Lambda function | `string` | n/a | yes |
| runtime | Lambda runtime | `string` | n/a | yes |
| handler | Function entrypoint | `string` | n/a | yes |
| description | Description of the Lambda function | `string` | `""` | no |
| filename | Path to the deployment package zip | `string` | `null` | no |
| s3\_bucket | S3 bucket containing the deployment package | `string` | `null` | no |
| s3\_key | S3 key of the deployment package | `string` | `null` | no |
| memory\_size | Amount of memory in MB | `number` | `128` | no |
| timeout | Function timeout in seconds | `number` | `30` | no |
| environment\_variables | Environment variables | `map(string)` | `{}` | no |
| vpc\_subnet\_ids | Subnet IDs for VPC configuration | `list(string)` | `[]` | no |
| vpc\_security\_group\_ids | Security group IDs for VPC configuration | `list(string)` | `[]` | no |
| layers | List of Lambda layer ARNs | `list(string)` | `[]` | no |
| reserved\_concurrent\_executions | Reserved concurrent executions | `number` | `-1` | no |
| log\_retention\_days | CloudWatch log retention in days | `number` | `14` | no |
| additional\_policy\_arns | Additional IAM policy ARNs | `list(string)` | `[]` | no |
| event\_source\_mappings | Event source mappings | `list(object)` | `[]` | no |
| publish | Publish as new version | `bool` | `false` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| function\_arn | ARN of the Lambda function |
| function\_name | Name of the Lambda function |
| function\_invoke\_arn | Invoke ARN of the Lambda function |
| role\_arn | ARN of the Lambda execution role |
| log\_group\_name | Name of the CloudWatch log group |
<!-- END_TF_DOCS -->
