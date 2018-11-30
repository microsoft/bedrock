variable "elasticsearch_client_endpoint" {
  type = "string"
}

variable "name" {
  type    = "string"
  default = "fluentd"
}

variable "namespace" {
  type    = "string"
  default = "fluentd"
}

variable "helm_install_timeout" {
  default = 1800
}
