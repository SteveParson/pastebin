
resource "aws_api_gateway_rest_api" "pastebin_api" {
  name = "PastebinApi"
}

resource "aws_api_gateway_resource" "snippet_resource" {
  rest_api_id = aws_api_gateway_rest_api.pastebin_api.id
  parent_id   = aws_api_gateway_rest_api.pastebin_api.root_resource_id
  path_part   = "snippets"
}

resource "aws_api_gateway_deployment" "pastebin_deployment" {
  depends_on = [
    aws_api_gateway_integration_response.post,
    aws_api_gateway_integration_response.get,
    aws_api_gateway_integration_response.options_200
  ]
  rest_api_id = aws_api_gateway_rest_api.pastebin_api.id
  stage_name  = "test"
}

resource "aws_api_gateway_model" "empty" {
  rest_api_id  = aws_api_gateway_rest_api.pastebin_api.id
  name         = "EmptyOptionsResponse"
  description  = "Empty Model"
  content_type = "application/json"
  schema = jsonencode({
    "$schema" : "http://json-schema.org/draft-04/schema#",
    "title" : "EmptySchema",
    "type" : "object",
  })
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.pastebin_api.id
  resource_id = aws_api_gateway_resource.snippet_resource.id
  http_method = aws_api_gateway_method.options_method.http_method

  type               = "MOCK"
  request_parameters = {}
  request_templates = {
    "application/json" : "{\n  \"statusCode\" : 200\n}\n"
  }
}

resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.pastebin_api.id
  resource_id   = aws_api_gateway_resource.snippet_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.pastebin_api.id
  resource_id = aws_api_gateway_resource.snippet_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST'", # Add any other methods you support
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" : ""
  }
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.pastebin_api.id
  resource_id = aws_api_gateway_resource.snippet_resource.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "EmptyOptionsResponse"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}
