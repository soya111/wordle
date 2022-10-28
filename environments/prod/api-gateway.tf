# API Gateway

resource "aws_api_gateway_account" "wordle" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name               = "cloudwatch_for_api_gateway"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_attachment" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

data "aws_iam_policy_document" "cloudwatch_assume_role" {
  statement {
    sid     = "CloudWatch"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["apigateway.amazonaws.com"]
      type        = "Service"
    }
  }
}





resource "aws_api_gateway_rest_api" "wordle" {
  name = "wordle"
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.wordle.id
  parent_id = aws_api_gateway_rest_api.wordle.root_resource_id
  path_part = "api"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.wordle.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.wordle.id
  resource_id             = aws_api_gateway_method.proxy.resource_id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.wordle.invoke_arn
}

# deploy setting

resource "aws_api_gateway_deployment" "wordle" {
  rest_api_id = aws_api_gateway_rest_api.wordle.id
  stage_name  = var.stage_name
  depends_on = [
    aws_api_gateway_integration.lambda,
  ]
  triggers = {
    redeployment = "${timestamp()}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_api_gateway_method_settings" "wordle" {
#   rest_api_id = aws_api_gateway_rest_api.wordle.id
#   stage_name = aws_api_gateway_deployment.wordle.stage_name
#   method_path = "*/*"
#   settings {
#     data_trace_enabled = true
#     logging_level = "INFO"
#   }
# }

# policy

# resource "aws_api_gateway_rest_api_policy" "wordle" {
#   rest_api_id = aws_api_gateway_rest_api.wordle.id
#   policy      = data.aws_iam_policy_document.policy_for_api_gateway.json
# }

# data "aws_iam_policy_document" "policy_for_api_gateway" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#     actions   = ["execute-api:Invoke"]
#     resources = ["${aws_api_gateway_rest_api.wordle.execution_arn}/*"]
#   }
# }
