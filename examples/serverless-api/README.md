# Serverless API

This example deploys a serverless REST API on AWS using API Gateway, Lambda, and DynamoDB.

## Architecture

```
Client -> API Gateway -> Lambda -> DynamoDB
                           |
                        S3 (Deployment Packages)
```

## Modules Used

| Module | Purpose |
|--------|---------|
| [API Gateway](../../modules/cdn/api-gateway/) | REST API with CORS |
| [Lambda](../../modules/compute/lambda/) | API request handler |
| [DynamoDB](../../modules/storage/dynamodb/) | NoSQL data store |
| [S3](../../modules/storage/s3/) | Lambda deployment packages |
| [IAM](../../modules/security/iam/) | Least-privilege policies |

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```
