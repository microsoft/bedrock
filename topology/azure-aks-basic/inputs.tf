/*
variable "aad_server_app_id" {
  type = "string"
}

variable "aad_server_app_secret" {
  type = "string"
}

variable "aad_client_app_id" {
  type = "string"
}

variable "aad_tenant_id" {
  type = "string"
}
*/

variable "client_id" {
  type = "string"
}

variable "client_secret" {
  type = "string"
}

variable "admin_user" {
  type = "string"
}

variable "ssh_public_key" {
  type = "string"
}

variable "cluster_name" {
    type   = "string"
}

variable "vnet_address_space" {
    type   = "string"
}

variable "resource_group_name" {
    type   = "string"
}

variable "resource_group_location" {
    type   = "string"
}

variable "subnet_address_space" {
    type    = "string"
}

variable "agent_vm_count" {
    type    = "string"
    default = "3"
}

variable "agent_vm_size" {
    type   = "string"
    default = "Standard_DS3_v2"
}

