resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  inline_policy {
    name = "lambda_exec_policy"

    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
        ],
        Effect = "Allow",
        Resource = [
          aws_dynamodb_table.snippets.arn,
          aws_dynamodb_table.rate_limiting.arn
        ]
      }]
    })
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "LambdaLogging"
  description = "Grant permissions to write logs to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging_attachment" {
  policy_arn = aws_iam_policy.lambda_logging.arn
  role       = aws_iam_role.lambda_exec.name
}

resource "aws_lambda_permission" "get" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_snippet.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.pastebin_api.execution_arn}/*"
}

resource "aws_lambda_permission" "post" {
  action        = "lambda:InvokeFunction"
  source_arn    = "${aws_api_gateway_rest_api.pastebin_api.execution_arn}/*"
  function_name = aws_lambda_function.post_snippet.function_name
  principal     = "apigateway.amazonaws.com"
}
