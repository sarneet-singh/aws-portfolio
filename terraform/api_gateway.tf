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
    depends_on = [ aws_api_gateway_method.contact_post, aws_api_gateway_integration.lambda_integration ]
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