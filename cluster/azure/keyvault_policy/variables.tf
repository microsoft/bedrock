variable "vault_name" {
    type = "string"
}

variable "resource_group_name" {
    type = "string"
}

variable "tenant_id" {
    type = "string"
}

variable "object_id" {
    type = "string"
}

variable "key_permissions" {
    type = "list"
    default = ["create", "delete", "get"]
}

variable "secret_permissions" {
    type = "list"
    default = ["delete", "get", "set"]
}