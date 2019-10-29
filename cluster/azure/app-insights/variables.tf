variable "resource_group_name" {
  type = "string"
}

variable "location" {
  description = "The location/region of resource group"
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

variable "contributor_object_ids" {
  type = "string"
  description = "comma-separated object id of aad usersg or roups"
  default = ""
}

variable "subscription_id" {
  type = "string"
  description = "azure subscription id where app insights is created"
}