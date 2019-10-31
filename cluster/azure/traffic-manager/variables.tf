variable "subscription_id" {
  type = "string"
  default = ""
}

variable "resource_group_name" {
  type = "string"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = "string"
}

variable "traffic_manager_name" {
  type = "string"
}

variable "service_names" {
  type = "string"
  description = "comma-separated service names that is exposed to internet via ingress, i.e. product-catalog-api"
  default = ""
}

variable "service_suffix" {
  type = "string"
  description = "suffix applied to cluster/env, such as dev1, dev2, so that ingress host name will be: product-catalog-api-dev2.dev.space.microsoft.com"
  default = ""
}

variable "dns_zone_name" {
  type = "string"
  description = "subdomain, i.e. dev.space.microsoft.com"
  default = ""
}

variable "probe_path" {
  type = "string"
  default = "/"
}
