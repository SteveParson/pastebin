resource "aws_route53_record" "pastebin" {
  zone_id = data.aws_route53_zone.existing.zone_id
  name    = local.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.pastebin.domain_name
    zone_id                = aws_cloudfront_distribution.pastebin.hosted_zone_id
    evaluate_target_health = false
  }
}
