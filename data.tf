data "aws_region" "current" {}

data "aws_route53_zone" "existing" {
  name = "${local.hosted_zone}."
}

locals {
  hosted_zone = "aws.steveparson.ca"
  domain = "pastebin.${local.hosted_zone}"
}
