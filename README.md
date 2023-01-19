# opensearch
OpenSearch module

# Description

This module allows the creation of an OpenSearch cluster

## Requirements
The module requires some pre conditions

## Usage
```hcl
module "opensearch" {
  source = "toluna-terraform/opensearch/aws"
  version = "~>0.0.1"  
  create_os                        = local.main.create_opensearch
  vpc_private_management_subnet_id = module.vpc.private_subnet_management_ids
  security_group_ids               = module.security_groups.all_name
  os_group                         = local.opensearch
  create_service_link_role         = local.main.create_service_link_role
  env_name                         = local.main.env_name
  env_type                         = local.main.env_type
  tags                             = local.tags
  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true",
    "override_main_response_version" = "true"
  }
}
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.26 |
| <a name="provider_elasticsearch"></a> [elasticsearch](#phillbaker/elasticsearch) | >= 1.6.2 |

## Resources

| Name | Type |
|------|------|
resource |
| [aws_iam_service_linked_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_opensearch_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain) | resource |
| [elasticsearch_opendistro_ism_policy](https://registry.terraform.io/providers/steveteuber/elasticsearch/latest/docs/resources/opendistro_ism_policy) | resource |

## Inputs
| Name | Description |
|------|------|
|create_os|Flag true/false |
|os_group|Variable pointing to json config file |
|create_service_link_role|Flag true/false. If role already exist set flag to false)|
|env_name|Environmanet name |
|env_type|Environmanet type (I.E. prod or non-prod)|
|tags|Tags|


## Example of json configuration to be used togheter with the variable os_group

```hcl
{
  "name-opensearch": {
    "domain_name": "os-name",
    "sg_names": ["your_sg_name"],
    "engine_version": "OpenSearch_1.0",
    "ebs_volume_size": 150,
    "ebs_volume_type": "gp3",
    "encrypt_at_rest" : true,
    "kms_key_id": "",
    "instance_count": 2,
    "instance_type": "r5.large.search",
    "dedicated_master_enabled" : false,
    "dedicated_master_count" : 0,
    "dedicated_master_type" : "m5.large.search",
    "zone_awareness_enabled" : true,
    "availability_zone_count" : 2,
    "node_to_node_encryption": true,
    "automated_snapshot_start_hour": "02",
    "create_iam_service_linked_role": false,
    "policy_names": []
  }
}
```
