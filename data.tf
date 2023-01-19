data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "issued" {
  domain   = "*.tolunainsights-internal.com"
  statuses = ["ISSUED"]
  most_recent = true
}


data "aws_route53_zone" "selected" {
  name         = "${join("", regexall("[a-z0-9]+", lower(var.env_name)))}.tolunainsights-internal.com"
  private_zone = true
}
