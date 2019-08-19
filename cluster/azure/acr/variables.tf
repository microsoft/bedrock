variable "resource_group_name" {
  type = "string"
}

variable "location" {
  description = "The location/region of resource group"
  type        = "string"
}

variable "alternate_location" {
  type        = "string"
  description = "failover location"
}

variable "name" {
  type        = "string"
  description = "name of acr"
}

variable "vault_name" {
  type        = "string"
  description = "Name of the keyvault to store associated secrets"
}

variable "acr_auth_secret_name" {
  type        = "string"
  description = "Secret name for username used to login docker"
}

variable "email" {
  type        = "string"
  description = "email of acr owner"
}
