variable "name" {
  type = "string"
}

variable "subscription_id" {
  type = "string"
  description = "azure subscription id where app insights is created"
}

variable "resource_group_name" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "capacity" {
  type    = "string"
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

variable "access_key_secret_version" {
  type = "string"
}


variable "hostname_secret_name" {
  type = "string"
}

variable "hostname_secret_version" {
  type = "string"
}
