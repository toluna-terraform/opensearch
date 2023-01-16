variable "env_name" {}
variable "env_type" {}
variable "security_group_ids" {}
variable "os_group" {}
variable "create_os" {}
variable "vpc_private_management_subnet_id" {}
variable "create_service_link_role" {}
# variable "access_policie" {}
variable "advanced_options" {
  type        = map(string)
  default     = {}
  description = "Key-value string pairs to specify advanced configuration options"
}

variable "tags" {}
