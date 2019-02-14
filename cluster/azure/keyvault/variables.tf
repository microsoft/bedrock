variable "keyvault_name" {
  description = "Name of the keyvault to create"
  default     = "acctkeyvault"
}

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  default     = "myapp-rg"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
}

variable "secret_name" {
  description = "The name of a secret to create."
}

variable "secret_value" {
  description = "The value of a secret being created."
}