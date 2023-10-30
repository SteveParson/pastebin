output "invoke_url" {
  value = "https://${aws_api_gateway_rest_api.pastebin_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_deployment.pastebin_deployment.stage_name}/${aws_api_gateway_resource.snippet_resource.path_part}"
}