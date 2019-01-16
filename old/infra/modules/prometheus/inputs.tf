variable "helm_install_timeout" {
  default = 1800
}

variable "name" {
  type    = "string"
  default = "prometheus"
}

variable "namespace" {
  type    = "string"
  default = "prometheus"
}

variable "prometheus_alertmanager_storage_class" {
  type    = "string"
  default = "default"
}

variable "prometheus_server_storage_class" {
  type    = "string"
  default = "default"
}

variable "prometheus_server_storage_size" {
  type    = "string"
  default = "default"
}
