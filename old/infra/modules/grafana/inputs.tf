variable "admin_user" {
  type = "string"
}

variable "admin_password" {
  type = "string"
}

variable "dashboard_yaml" {
  type    = "string"
  default = ""
}

variable "helm_install_timeout" {
  default = 1800
}

variable "name" {
  type    = "string"
  default = "grafana"
}

variable "namespace" {
  type    = "string"
  default = "grafana"
}

variable "persistence_enabled" {
  type    = "string"
  default = "true"
}

variable "prometheus_service_endpoint" {
  type = "string"
}

variable "storage_class" {
  type    = "string"
  default = "default"
}

variable "storage_size" {
  type    = "string"
  default = "4Gi"
}
