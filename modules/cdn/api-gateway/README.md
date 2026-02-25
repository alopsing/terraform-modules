# AWS API Gateway Module

Terraform module to create REST API Gateway with resources, methods, integrations, authorizers, API keys, usage plans, and CORS support.

## Features

- REST API with configurable endpoint type (EDGE, REGIONAL, PRIVATE)
- Dynamic resource and method creation
- Lambda proxy and custom integrations
- Cognito and Lambda authorizers
- API keys with usage plans and throttling
- CORS support with configurable origins, methods, and headers
- Automatic deployment and stage management
- Consistent resource tagging

## Usage

### Basic

```hcl
module "api_gateway" {
  source = "../../modules/cdn/api-gateway"

  name        = "my-app"
  environment = "dev"
  api_name    = "my-api"
  description = "My application API"

  resources = {
    users = {
      path_part = "users"
      methods = {
        get = {
          http_method     = "GET"
          integration_uri = "arn:aws:apigateway:us-east-1:lambda:path/..."
        }
      }
    }
  }
}
```

### With Auth, API Keys, and CORS

```hcl
module "api_gateway" {
  source = "../../modules/cdn/api-gateway"

  name        = "my-app"
  environment = "prod"
  api_name    = "main-api"

  resources = {
    users = {
      path_part = "users"
      methods = {
        get = {
          http_method    = "GET"
          authorization  = "COGNITO_USER_POOLS"
          authorizer_key = "cognito"
          integration_uri = "arn:aws:apigateway:..."
        }
      }
    }
  }

  authorizers = {
    cognito = {
      type          = "COGNITO_USER_POOLS"
      provider_arns = ["arn:aws:cognito-idp:..."]
    }
  }

  enable_cors    = true
  enable_api_key = true

  usage_plan = {
    name               = "standard"
    throttle_burst_limit = 200
    throttle_rate_limit  = 100
    quota_limit          = 50000
    quota_period         = "MONTH"
  }
}
```

## Examples

- [Basic](examples/basic/) — Simple REST API with Lambda integration
- [Complete](examples/complete/) — API with Cognito auth, CORS, API keys, and usage plans

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for resources | `string` | n/a | yes |
| environment | Environment name (dev, staging, prod) | `string` | n/a | yes |
| api\_name | Name of the API Gateway | `string` | n/a | yes |
| description | Description of the API | `string` | `""` | no |
| stage\_name | Name of the deployment stage | `string` | `"v1"` | no |
| endpoint\_type | Endpoint type (EDGE, REGIONAL, PRIVATE) | `string` | `"REGIONAL"` | no |
| resources | Map of API resources and methods | `map(object)` | `{}` | no |
| authorizers | Map of API Gateway authorizers | `map(object)` | `{}` | no |
| enable\_api\_key | Enable API key requirement | `bool` | `false` | no |
| usage\_plan | Usage plan configuration | `object` | `null` | no |
| enable\_cors | Enable CORS support | `bool` | `false` | no |
| cors\_allow\_origins | Allowed origins for CORS | `list(string)` | `["*"]` | no |
| cors\_allow\_methods | Allowed methods for CORS | `list(string)` | `["GET","POST","PUT","DELETE","OPTIONS"]` | no |
| cors\_allow\_headers | Allowed headers for CORS | `list(string)` | `["Content-Type","Authorization"]` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| api\_id | ID of the REST API |
| api\_arn | ARN of the REST API |
| execution\_arn | Execution ARN of the REST API |
| invoke\_url | Invoke URL for the API stage |
| stage\_name | Name of the deployed stage |
| api\_key\_value | API key value (sensitive) |
<!-- END_TF_DOCS -->
