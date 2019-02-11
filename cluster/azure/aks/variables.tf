
variable "resource_group_name" {
    type = "string"
}

variable "cluster_name" {
    type = "string"
}

variable "cluster_location" {
    type = "string"
}

variable "dns_prefix" {
    type = "string"
}

variable "client_id" {
    type = "string"
}

variable "client_secret" {
    type = "string"
}

variable "agent_vm_count" {
    type = "string"
}

variable "agent_vm_size" {
    type = "string"
}

variable "kubernetes_version" {
    type = "string"
    default = "1.12.4"
}

variable "admin_user" {
    type = "string"
}

variable "ssh_public_key" {
    type = "string"
}

variable "output_directory" {
    type = "string"
}

variable "vnet_subnet_id" {
    type = "string"
}