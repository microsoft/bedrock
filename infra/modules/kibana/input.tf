variable "elasticsearch_client_endpoint" {
  type = "string"
}

variable "helm_install_timeout" {
  default = 1800
}

variable "name" {
  type    = "string"
  default = "kibana"
}

variable "namespace" {
  type    = "string"
  default = "kibana"
}
