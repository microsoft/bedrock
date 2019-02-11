
variable "resource_group_name" {
    type = "string"
}

variable "cluster_name" {
    type = "string"
    default = "bedrockaks"
}

variable "cluster_location" {
    type = "string"
}

variable "dns_prefix" {
    type = "string"
}

variable "service_principal_id" {
    type = "string"
}

variable "service_principal_secret" {
    type = "string"
}

variable "agent_vm_count" {
    type = "string"
    default = "2"
}

variable "agent_vm_size" {
    type = "string"
    default = "Standard_D2s_v3"
}

variable "kubernetes_version" {
    type = "string"
    default = "1.12.4"
}

variable "admin_user" {
    type = "string"
    default = "k8sadmin"
}

variable "ssh_public_key" {
    type = "string"
}

variable "output_directory" {
    type = "string"
    default = "./output"
}

variable "vnet_subnet_id" {
    type = "string"
}

variable "enable_virtual_node_addon" {
    type = "string"
    default = "false"
}

variable "enable_cluster_creds_to_disk" {
    type = "string"
    default = "true"
}