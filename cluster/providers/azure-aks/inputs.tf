variable "agent_vm_count" {
  type = "string"
}

variable "agent_vm_size" {
  default = "Standard_DS3_v2"
}

variable "kubernetes_version" {
  default = "1.11.4"
}

variable "master_vm_count" {
  default = "3"
}

variable "master_vm_size" {
  default = "Standard_DS1_v2"
}

variable "admin_user" {}

variable "ssh_public_key" {}

variable "location" {}

variable "subnet_address_space" {}

variable "vnet_address_space" {}

variable "first_master_ip" {}

variable "cluster_name" {}

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

variable "client_id" {}

variable "client_secret" {}
