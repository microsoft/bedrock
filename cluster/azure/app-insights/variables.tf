variable "resource_group_name" {
  type = "string"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = "string"
}

variable "name" {
  type = "string"
  description = "name of app insights"
}

variable "vault_name" {
  type        = "string"
  description = "Name of the keyvault to store instrumentation key"
}

variable "instrumentation_key_secret_name" {
  type        = "string"
  description = "Secret name used to store instrumentation key"
}

variable "app_id_secret_name" {
  type        = "string"
  description = "Secret name used to store app insights app id"
}
