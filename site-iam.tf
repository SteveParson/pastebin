data "aws_iam_policy_document" "pastebin" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.pastebin.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.pastebin.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.pastebin.arn]


    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.pastebin.iam_arn]
    }
  }
}
