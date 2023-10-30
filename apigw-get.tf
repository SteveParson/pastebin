resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.pastebin_api.id
  resource_id   = aws_api_gateway_resource.snippet_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "get" {
  depends_on  = [aws_api_gateway_method.get]
  rest_api_id = aws_api_gateway_rest_api.pastebin_api.id
  resource_id = aws_api_gateway_resource.snippet_resource.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "get" {
  rest_api_id             = aws_api_gateway_rest_api.pastebin_api.id
  resource_id             = aws_api_gateway_resource.snippet_resource.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_snippet.invoke_arn
}

resource "aws_api_gateway_integration_response" "get" {
  depends_on  = [aws_api_gateway_integration.get]
  rest_api_id = aws_api_gateway_rest_api.pastebin_api.id
  resource_id = aws_api_gateway_resource.snippet_resource.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'*'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}
