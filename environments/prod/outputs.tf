output "base_url" {
  value = aws_api_gateway_deployment.wordle.invoke_url
}
