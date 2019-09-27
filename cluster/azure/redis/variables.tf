variable "name" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "capacity" {
  type    = number
  default = 2
}

variable "family" {
  type    = "string"
  default = "C"
}

variable "sku_name" {
  type    = "string"
  default = "Standard"
}

variable "vault_name" {
  type = "string"
}

variable "access_key_secret_name" {
  type = "string"
}

variable "hostname_secret_name" {
  type = "string"
}