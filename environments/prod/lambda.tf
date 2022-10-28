resource "null_resource" "go_build" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "GOOS=linux GOARCH=amd64 go build -o handler ../../cmd/webhook/main.go"
  }
}

data "archive_file" "go" {
  depends_on  = [null_resource.go_build]
  type        = "zip"
  source_file = "handler"
  output_path = "handler.zip"
}

resource "aws_lambda_function" "wordle" {
  filename      = data.archive_file.go.output_path
  function_name = var.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "handler"
  runtime       = "go1.x"
  timeout       = "15"
  environment {
    variables = {
      "CHANNEL_SECRET" = var.channel_secret
      "CHANNEL_TOKEN"  = var.channel_token
    }
  }
}

resource "aws_lambda_permission" "wordle" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.wordle.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.wordle.execution_arn}/*/*"
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "attach_lambda_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "attach_dynamo_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid     = "Lambda"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}
