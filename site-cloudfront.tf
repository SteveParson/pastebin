resource "aws_cloudfront_distribution" "pastebin" {

  origin {
    domain_name = aws_s3_bucket.pastebin.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.pastebin.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.pastebin.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [local.domain]
  price_class         = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.pastebin.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.pastebin.bucket

    forwarded_values {
      query_string = true
      headers      = ["Access-Control-Allow-Origin"]
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# Need to create extra records manually in Route 53 for DNS validation
resource "aws_acm_certificate" "pastebin" {
  domain_name       = local.domain
  validation_method = "DNS"
}

resource "aws_cloudfront_origin_access_identity" "pastebin" {
  comment = "OAI for ${local.domain}"
}
