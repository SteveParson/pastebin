resource "aws_dynamodb_table" "snippets" {
  name         = "snippets"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "snippet"

  attribute {
    name = "snippet"
    type = "S"
  }
}

resource "aws_dynamodb_table" "rate_limiting" {
  name         = "RateLimitingTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ip"

  attribute {
    name = "ip"
    type = "S"
  }

  ttl {
    attribute_name = "expiryTime"
    enabled        = true
  }
}

resource "aws_dynamodb_table_item" "default_item" {
  table_name = aws_dynamodb_table.snippets.name
  hash_key   = "snippet"

  item = jsonencode({
    snippet = { "S" : "test" },
    content = { "S" : "testing" }
  })
}
