variable "subscription_id" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "name" {
  type = "string"
}

variable "service_names" {
  type = "string"
  description = "comma-separated service names that is exposed to internet via ingress, i.e. product-catalog-api"
}

variable "service_suffix" {
  type = "string"
  description = "suffix applied to cluster/env, such as dev1, dev2, so that ingress host name will be: product-catalog-api-dev2.dev.space.microsoft.com"
}

variable "domain_name" {
  type = "string"
  description = "subdomain, i.e. dev.space.microsoft.com"
}
