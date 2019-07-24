variable "enable_pod_identity" {
  type    = "string"
  default = "true"
}

variable "resource_group_name" {
  type = "string"
}

variable "service_principal_id" {
  type = "string"
}

variable "identity_name" {
  type = "string"
}