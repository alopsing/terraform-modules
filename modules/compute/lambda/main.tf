################################################################################
# Lambda Function
################################################################################

resource "aws_lambda_function" "this" {
  function_name = "${local.name_prefix}-${var.function_name}"
  description   = var.description
  role          = aws_iam_role.this.arn

  runtime     = var.runtime
  handler     = var.handler
  memory_size = var.memory_size
  timeout     = var.timeout
  publish     = var.publish

  filename         = var.filename
  source_code_hash = var.filename != null ? filebase64sha256(var.filename) : null
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key

  layers                         = var.layers
  reserved_concurrent_executions = var.reserved_concurrent_executions

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  dynamic "vpc_config" {
    for_each = local.has_vpc ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${var.function_name}"
  })

  depends_on = [aws_cloudwatch_log_group.this]
}

################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.name_prefix}-${var.function_name}"
  retention_in_days = var.log_retention_days

  tags = local.common_tags
}

################################################################################
# IAM Execution Role
################################################################################

resource "aws_iam_role" "this" {
  name = "${local.name_prefix}-${var.function_name}-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc_access" {
  count = local.has_vpc ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "additional" {
  count = length(var.additional_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = var.additional_policy_arns[count.index]
}

################################################################################
# Event Source Mappings
################################################################################

resource "aws_lambda_event_source_mapping" "this" {
  count = length(var.event_source_mappings)

  function_name     = aws_lambda_function.this.arn
  event_source_arn  = var.event_source_mappings[count.index].event_source_arn
  batch_size        = var.event_source_mappings[count.index].batch_size
  starting_position = var.event_source_mappings[count.index].starting_position
  enabled           = var.event_source_mappings[count.index].enabled
}
