variable "output_directory" {
    type    = "string"
    default = "./output"
}

variable "resource_group_name" {
    type    = "string"
    default = "tf-aks-basic-rg"
}

variable "resource_group_location" {
    type    = "string"
    default = "westus2"
}

variable "cluster_name" {
    type    = "string"
    default = "tf-aks-basic-cluster"
}

variable "service_principal_id" {
    type    = "string"
}

variable "service_principal_secret" {
    type    = "string"
}

variable "admin_user" {
    type    = "string"
    default = "azureuser"
}

variable "ssh_public_key" {
    type = "string"
}
