variable "helm_install_timeout" {
  default = 1800
}

variable "name" {
  type    = "string"
  default = "kured"
}

variable "namespace" {
  type    = "string"
  default = "kube-system"
}

variable "prometheus_service_endpoint" {
  type    = "string"
  default = "default"
}
