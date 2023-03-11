data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "resume" {
  name = "VisitorCountAPI"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "resume" {
  rest_api_id = aws_api_gateway_rest_api.resume.id
  parent_id   = aws_api_gateway_rest_api.resume.root_resource_id
  path_part   = "count"
}

resource "aws_api_gateway_method" "resume" {
  rest_api_id   = aws_api_gateway_rest_api.resume.id
  resource_id   = aws_api_gateway_resource.resume.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.resume.id
  resource_id = aws_api_gateway_resource.resume.id
  http_method = aws_api_gateway_method.resume.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.resume.id
  resource_id             = aws_api_gateway_resource.resume.id
  http_method             = aws_api_gateway_method.resume.http_method
  content_handling        = "CONVERT_TO_TEXT"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda.invoke_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_deployment" "resume" {
  rest_api_id = aws_api_gateway_rest_api.resume.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.resume.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "resume" {
  deployment_id = aws_api_gateway_deployment.resume.id
  rest_api_id   = aws_api_gateway_rest_api.resume.id
  stage_name    = "production"
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.resume.id}/*/${aws_api_gateway_method.resume.http_method}${aws_api_gateway_resource.resume.path}"
}

resource "aws_api_gateway_integration_response" "resume" {
  rest_api_id = aws_api_gateway_rest_api.resume.id
  resource_id = aws_api_gateway_resource.resume.id
  http_method = aws_api_gateway_method.resume.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}
