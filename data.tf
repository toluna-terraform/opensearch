data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "issued" {
  domain   = "*.tolunainsights-internal.com"
  statuses = ["ISSUED"]
  most_recent = true
}
