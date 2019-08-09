variable "keyvault_name" {
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
