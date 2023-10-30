resource "aws_s3_bucket" "pastebin" {
  bucket = "www-${local.domain}"
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["Access-Control-Allow-Origin"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "pastebin" {
  bucket = aws_s3_bucket.pastebin.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

resource "aws_s3_object" "pastebin" {
  for_each = fileset("${path.module}/website", "*")

  bucket = aws_s3_bucket.pastebin.bucket
  key    = each.value
  source = "website/${each.value}"
  etag   = filemd5("website/${each.value}")
  content_type = lookup({
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
  }, split(".", each.value)[1], "text/plain")
}

resource "aws_s3_bucket_policy" "pastebin" {
  bucket = aws_s3_bucket.pastebin.id
  policy = data.aws_iam_policy_document.pastebin.json
}
