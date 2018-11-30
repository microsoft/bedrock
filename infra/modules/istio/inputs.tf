variable "helm_install_timeout" {
  default = 1800
}

variable "istio_version" {
  type    = "string"
  default = "1.0.4"
}

variable "name" {
  type    = "string"
  default = "istio"
}

variable "namespace" {
  type    = "string"
  default = "istio-system"
}
