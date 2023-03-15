module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  create_api_domain_name = false

  name          = "visitor-count"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["PUT"]
    allow_origins = ["*"]
  }

  integrations = {
    "PUT /count" = {
      lambda_arn             = aws_lambda_function.lambda.arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }
  }

  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.logs.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"


  tags = {
    Terraform = "true"
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*"
}

resource "aws_cloudwatch_log_group" "logs" {
  name = aws_lambda_function.lambda.function_name
}
