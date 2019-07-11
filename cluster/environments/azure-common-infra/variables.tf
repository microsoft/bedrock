variable "address_space" {
  type = "string"
}

variable "keyvault_name" {
  type = "string"
}

variable "global_resource_group_name" {
  type = "string"
}

variable "global_resource_group_location" {
  type = "string"
}

variable "global_resource_group_preallocated" {
  description = "boolean value that when set to true, the specified resource group is assumed to exist.  it will not be feleted.  when set to false, the resource group will be 'managed' by Terraform and deleted on a 'terraform destroy'"
  default = false
}

variable "service_principal_id" {
  type = "string"
}

variable "subnet_name" {
  type = "string"
}

variable "subnet_prefix" {
  type = "string"
}

variable "vnet_name" {
  type = "string"
}
