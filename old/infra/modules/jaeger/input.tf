variable "name" {
  default = "jaeger"
}

variable "namespace" {
  default = "jaeger"
}

variable "helm_install_timeout" {
  default = 1800
}

variable "elasticsearch_client_endpoint" {
  type = "string"
}

variable "elasticsearch_port" {
  default = 9200
}
