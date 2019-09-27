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
