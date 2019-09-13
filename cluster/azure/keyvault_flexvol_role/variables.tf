variable "enable_flexvol" {
  type    = "string"
  default = "true"
}

variable "flexvol_role_assignment_role" {
  description = "The role to give the AKS service principal to access the keyvault"
  type        = "string"
  default     = "Reader"
}

variable "vault_name" {
  description = "The name of the keyvault that will be associated with the flex volume."
  type        = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "service_principal_object_id" {
  type = "string"
}

variable "subscription_id" {
  type = "string"
}
