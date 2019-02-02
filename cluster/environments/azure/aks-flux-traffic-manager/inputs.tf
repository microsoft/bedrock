variable "resource_group_name" {
    type = "string"
}

variable "resource_group_location" {
    type = "string"
    default = "westus2"
}

variable "cluster01_name" {
    type = "string"
}

variable "cluster01_location" {
    type = "string"
    default = "westus2"
}

variable "dns01_prefix" {
    type = "string"
}

variable "cluster02_name" {
    type = "string"
}

variable "cluster02_location" {
    type = "string"
    default = "eastus2"
}

variable "dns02_prefix" {
    type = "string"
}

variable "subnet_address_space" {
    type = "string"
    default = "10.200.0.0/16"
}

variable "vnet_address_space" {
    type = "string"
    default = "10.200.0.0/16"
}

variable "agent_vm_count" {
    type = "string"
    default = "3"
}

variable "agent_vm_size" {
    type = "string"
    default = "Standard_DS3_v2"
}

variable "admin_user" {
    type = "string"
    default = "azureuser"
}

variable "ssh_public_key" {
    type = "string"
}

variable "service_principal_id" {
    type = "string"
}

variable "service_principal_secret" {
    type = "string"
}

variable "flux_repo_url" {
  type = "string"
  default = "https://github.com/weaveworks/flux.git"
}

variable "gitops_url" {
  type = "string"
}

variable "gitops_ssh_key" {
  type    = "string"
}

variable "output_directory" {
    type = "string"
    default = "./output"
}

variable "global_resource_group_name" {
    type="string"
}

variable "global_resource_group_location" {
    type="string"
}
