################################################################################
# REST API
################################################################################

resource "aws_api_gateway_rest_api" "this" {
  name        = "${local.name_prefix}-${var.api_name}"
  description = var.description

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${var.api_name}"
  })
}

################################################################################
# Resources
################################################################################

resource "aws_api_gateway_resource" "this" {
  for_each = var.resources

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.path_part
}

################################################################################
# Methods & Integrations
################################################################################

resource "aws_api_gateway_method" "this" {
  for_each = {
    for rm in local.resource_methods : "${rm.resource_key}-${rm.method_key}" => rm
  }

  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.this[each.value.resource_key].id
  http_method      = each.value.http_method
  authorization    = each.value.authorization
  authorizer_id    = each.value.authorizer_key != null ? aws_api_gateway_authorizer.this[each.value.authorizer_key].id : null
  api_key_required = var.enable_api_key
}

resource "aws_api_gateway_integration" "this" {
  for_each = {
    for rm in local.resource_methods : "${rm.resource_key}-${rm.method_key}" => rm
  }

  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this[each.value.resource_key].id
  http_method             = aws_api_gateway_method.this[each.key].http_method
  type                    = each.value.integration_type
  integration_http_method = each.value.integration_type == "AWS_PROXY" ? "POST" : null
  uri                     = each.value.integration_uri
}

################################################################################
# CORS (OPTIONS method)
################################################################################

resource "aws_api_gateway_method" "cors" {
  for_each = var.enable_cors ? var.resources : {}

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this[each.key].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors" {
  for_each = var.enable_cors ? var.resources : {}

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.key].id
  http_method = aws_api_gateway_method.cors[each.key].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "cors" {
  for_each = var.enable_cors ? var.resources : {}

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.key].id
  http_method = aws_api_gateway_method.cors[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "cors" {
  for_each = var.enable_cors ? var.resources : {}

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.key].id
  http_method = aws_api_gateway_method.cors[each.key].http_method
  status_code = aws_api_gateway_method_response.cors[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.cors_allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.cors_allow_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${join(",", var.cors_allow_origins)}'"
  }
}

################################################################################
# Authorizers
################################################################################

resource "aws_api_gateway_authorizer" "this" {
  for_each = var.authorizers

  rest_api_id     = aws_api_gateway_rest_api.this.id
  name            = "${local.name_prefix}-${each.key}"
  type            = each.value.type
  provider_arns   = each.value.type == "COGNITO_USER_POOLS" ? each.value.provider_arns : null
  authorizer_uri  = each.value.type != "COGNITO_USER_POOLS" ? each.value.authorizer_uri : null
  identity_source = each.value.identity_source
}

################################################################################
# Deployment & Stage
################################################################################

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.this,
      aws_api_gateway_method.this,
      aws_api_gateway_integration.this,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.this,
    aws_api_gateway_integration.this,
  ]
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.stage_name
  description   = var.stage_description

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${var.stage_name}"
  })
}

################################################################################
# API Key & Usage Plan
################################################################################

resource "aws_api_gateway_api_key" "this" {
  count = var.enable_api_key ? 1 : 0

  name    = var.api_key_name != "" ? var.api_key_name : "${local.name_prefix}-${var.api_name}-key"
  enabled = true

  tags = local.common_tags
}

resource "aws_api_gateway_usage_plan" "this" {
  count = var.usage_plan != null ? 1 : 0

  name = var.usage_plan.name

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }

  throttle_settings {
    burst_limit = var.usage_plan.throttle_burst_limit
    rate_limit  = var.usage_plan.throttle_rate_limit
  }

  quota_settings {
    limit  = var.usage_plan.quota_limit
    period = var.usage_plan.quota_period
  }

  tags = local.common_tags
}

resource "aws_api_gateway_usage_plan_key" "this" {
  count = var.enable_api_key && var.usage_plan != null ? 1 : 0

  key_id        = aws_api_gateway_api_key.this[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this[0].id
}
