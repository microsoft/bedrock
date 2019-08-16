variable "vault_name" {
  description = "Name of the keyvault to create"
  default     = "acctkeyvault"
}

variable "keyvault_sku" {
  description = "SKU of the keyvault to create"
  default     = "standard"
}

variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  default     = "myapp-rg"
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type        = "string"
}

variable "service_principal_object_id" {
  type = "string"
  description = "terraform service principal object id"
}
