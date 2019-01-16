variable "service_principal_id" {
  type = "string"
}

variable "service_principal_secret" {
  type = "string"
}

variable "admin_user" {
  type = "string"
  default = "azureuser"
}

variable "ssh_public_key" {
  type = "string"
}
