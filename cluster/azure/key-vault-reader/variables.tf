variable "keyvault_name" {
  description = "Name of the keyvault to create"
}

variable "keyvault_sku" {
  description = "SKU of the keyvault to create"
  default     = "standard"
}

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = "string"
}

variable "service_principal_name" {
  description = "service principal name that will be granted reader role to key vault. The service principal musbe by unique with this name"
  type        = "string"
}
