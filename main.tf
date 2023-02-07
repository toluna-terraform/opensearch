resource "aws_cloudwatch_log_group" "this" {
    for_each = var.create_os ? var.os_group : {}
    name = "/aws/OpenSearchService/domains/${each.value.domain_name}-${var.env_name}/application-logs"

    tags = merge(
    var.tags,
    tomap({
      "Name" = "os-${var.env_name}-${each.value.domain_name}",
      "environment" = var.env_name,
      "product" = "opensearch",
      "application_role" = "network",
      "created_by" = "terraform"}
    )
  )
}

resource "aws_cloudwatch_log_resource_policy" "this" {
  policy_name = "CloudWatch Access"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

resource "aws_iam_service_linked_role" "os" {
  
  count            = var.create_service_link_role ? 1 : 0   #if account for aws_service_name already exist you must set the flag to false otherwise it will fail
  aws_service_name = "es.amazonaws.com"
  description      = "AWSServiceRoleForAmazonOpensearchService Service-Linked Role"
}

resource "aws_opensearch_domain" "os" {
  for_each              = var.create_os ? var.os_group : {}
  domain_name           = "${each.value.domain_name}-${var.env_name}"
  engine_version        = each.value.engine_version

#  # advanced_options = var.advanced_options
#domain_endpoint_options {
#  custom_endpoint_enabled = true
#  custom_endpoint_certificate_arn = data.aws_acm_certificate.issued.arn
#  custom_endpoint = "${each.key}-${replace(var.env_name,"-","")}.tolunainsights-internal.com"
#}


  ebs_options {
    ebs_enabled = each.value.ebs_volume_size > 0 ? true : false
    volume_size = each.value.ebs_volume_size
    volume_type = each.value.ebs_volume_type
  }

  encrypt_at_rest {
    enabled    = each.value.encrypt_at_rest
    kms_key_id = each.value.kms_key_id
  }

  cluster_config {
    instance_count           = each.value.instance_count
    instance_type            = each.value.instance_type
    dedicated_master_enabled = each.value.dedicated_master_enabled
    dedicated_master_count   = each.value.dedicated_master_count
    dedicated_master_type    = each.value.dedicated_master_type
    zone_awareness_enabled   = each.value.zone_awareness_enabled

    zone_awareness_config {
      availability_zone_count = each.value.availability_zone_count
    }
  }


  node_to_node_encryption {
    enabled = each.value.node_to_node_encryption
  }

  vpc_options {
    security_group_ids = [for sg_name in each.value.sg_names : var.security_group_ids[0][sg_name]["id"]]
    subnet_ids         = slice(var.vpc_private_management_subnet_id, 0, each.value.availability_zone_count)
  }

  snapshot_options {
    automated_snapshot_start_hour = each.value.automated_snapshot_start_hour
  }

  advanced_options = var.advanced_options

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": {
              "AWS": "*"
            },
            "Effect": "Allow",
            "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${each.value.domain_name}-${var.env_name}/*"
        }
    ]
}
CONFIG




    //cloudwatch_log_group_arn = aws_cloudwatch_log_group.this[each.key].arn
    //log_type = each.value.log_type[0]
    log_publishing_options = [
    {
      cloudwatch_log_group_arn = aws_cloudwatch_log_group.os_log_group.arn,
      log_level                = each.value.log_level
    },
  ]

  tags = merge(
    var.tags,
    tomap({
      "Name" = "os-${var.env_name}-${each.value.domain_name}",
      "environment" = var.env_name,
      "product" = "opensearch",
      "application_role" = "network",
      "created_by" = "terraform"}
    )
  )

  depends_on = [aws_iam_service_linked_role.os]
}

provider "elasticsearch" {
    url = "https://os-logsystem-${var.env_name}"
}

locals {
  policy_names = flatten([
    for os_key, os_group in var.os_group :[
        for policy_key, policy in os_group.policy_names : {
            os_key = os_key
            policy_key = policy
          }
        ]
  ])
}

resource "aws_route53_record" "logging_service_record" {
  for_each = var.create_os ? var.os_group : {}
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "opensearch"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_opensearch_domain.os[each.key].endpoint]
}