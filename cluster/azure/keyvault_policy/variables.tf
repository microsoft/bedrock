variable "vault_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "object_id" {
  type = string
}

variable "enabled" {
  type    = bool
  default = true
}

variable "key_permissions" {
  type    = list
  default = ["create", "delete", "get"]
}

variable "secret_permissions" {
  type    = list
  default = ["delete", "get", "set"]
}
