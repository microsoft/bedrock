variable "helm_install_timeout" {
  default = 1800
}

variable "istio_version" {
  type    = "string"
  default = "1.0.4"
}

variable "kiala_admin_username" {
  type    = "string"
  default = "ops"
}

variable "kiala_admin_password" {
  type = "string"
}

variable "name" {
  type    = "string"
  default = "istio"
}

variable "namespace" {
  type    = "string"
  default = "istio-system"
}

variable "prometheus_service_endpoint" {
  type = "string"
}
