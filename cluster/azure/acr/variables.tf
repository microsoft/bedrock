variable "resource_group_name" {
  type = string
}

variable "enable_acr" {
  type    = string
  default = "false"
}

variable "acr_name" {
  type = string
}
