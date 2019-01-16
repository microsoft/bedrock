variable "name" {
  type    = "string"
  default = "elasticsearch"
}

variable "namespace" {
  type    = "string"
  default = "elasticsearch"
}

variable "elasticsearch_master_storage_class" {
  type    = "string"
  default = "default"
}

variable "elasticsearch_master_storage_size" {
  type    = "string"
  default = "4Gi"
}

variable "elasticsearch_data_storage_class" {
  type    = "string"
  default = "default"
}

variable "elasticsearch_data_storage_size" {
  type    = "string"
  default = "31Gi"
}

variable "helm_install_timeout" {
  default = 1800
}
