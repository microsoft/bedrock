variable "keyvault_name" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "service_principal_id" {
  type = "string"
}

variable "key_permissions" {
  type    = "list"
  default = ["create", "delete", "get"]
}

variable "secret_permissions" {
  type    = "list"
  default = ["delete", "get", "set"]
}

variable "certificate_permissions" {
  type    = "list"
  default = ["delete", "get", "create"]
}

variable "precursor_done" {
  type    = "string"
  default = "1"
}