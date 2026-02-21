resource "aws_api_gateway_rest_api" "contact_api" {
    name = "${var.project_name}-${var.environment}-rest-api"
    description = "REST API for contact form"
  
}

resource "aws_api_gateway_resource" "contact_resource" {
    rest_api_id = aws_api_gateway_rest_api.contact_api.id
    parent_id = aws_api_gateway_rest_api.contact_api.root_resource_id
    path_part = "contact"
}


resource "aws_api_gateway_method" "contact_post" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = "POST"
  authorization = "NONE"

}

resource "aws_api_gateway_integration" "lambda_integration" {
    rest_api_id = aws_api_gateway_rest_api.contact_api.id
    resource_id = aws_api_gateway_resource.contact_resource.id
    http_method = aws_api_gateway_method.contact_post.http_method
    integration_http_method = "POST"
    type = "AWS_PROXY"
    uri = aws_lambda_function.contact_handler.invoke_arn
  
}

resource "aws_api_gateway_deployment" "contact_deployment" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.contact_resource.id,
      aws_api_gateway_method.contact_post.id,
      aws_api_gateway_integration.lambda_integration.id,
      aws_api_gateway_method.options.id,
      aws_api_gateway_integration.options.id,
      aws_api_gateway_integration_response.options.id,
    ]))
  }

  depends_on = [
    aws_api_gateway_method.contact_post,
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_method.options,
    aws_api_gateway_integration_response.options,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "contact_stage" {
    rest_api_id = aws_api_gateway_rest_api.contact_api.id
    deployment_id = aws_api_gateway_deployment.contact_deployment.id
    stage_name = var.environment
  
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_handler.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.contact_api.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.contact_api.id
  resource_id   = aws_api_gateway_resource.contact_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  resource_id = aws_api_gateway_resource.contact_resource.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options]
}