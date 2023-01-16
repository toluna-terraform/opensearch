terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    elasticsearch = {
      source  = "phillbaker/elasticsearch"
      version = "1.6.2"
    }
  }
}
