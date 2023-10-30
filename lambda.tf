resource "aws_lambda_function" "post_snippet" {
  filename      = "lambda-src/lambda.zip"
  function_name = "postSnippet"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "snippets.postSnippet"
  runtime       = "nodejs14.x"
  tags          = { "id" : filemd5("lambda-src/lambda.zip") }

  environment {
    variables = {
      DYNAMODB_TABLE   = aws_dynamodb_table.snippets.name,
      RATE_LIMIT_TABLE = aws_dynamodb_table.rate_limiting.name
    }
  }
}

resource "aws_lambda_function" "get_snippet" {
  filename      = "lambda-src/lambda.zip"
  function_name = "getSnippet"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "snippets.getSnippet"
  runtime       = "nodejs14.x"
  tags          = { "id" : filemd5("lambda-src/lambda.zip") }
  environment {
    variables = {
      DYNAMODB_TABLE   = aws_dynamodb_table.snippets.name,
      RATE_LIMIT_TABLE = aws_dynamodb_table.rate_limiting.name
    }
  }
}
