variable "resource_group_name" {
  type = "string"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = "string"
}

variable "name" {
  type = "string"
  description = "name of dns zone, redirect traffic under a zone, i.e. dev.1cs.io"
}

variable "service_principal_id" {
  type = "string"
  description = "service principal app_id or object_id who can read and write dns text records"
}

variable "caa_issuer" {
  type = "string"
  description = "name of issuer that can be trusted, i.e. letsencrypt.org"
}
